`timescale 1ns / 1ps

        module SPDIFdecoder(
    input SPDIFin,
	 output [1:0] BMCdec,
    input clk,
	 output reg edgeclk=0,
    output reg clkout=0,
    output reg [27:0] Dout=0,
	 output reg [1:0] synccode=0,//B=1,M=2,W=3,ERROR=0
		output reg parityOK=0,//パリティチェック結果が正しければ1,誤りで0(paritycheck:OK=1,NG=0)
	 output [23:0] AudioL,
	 output [23:0] AudioR,
	 output reg Audioclk=0
	 
	 
    );
	 
	 reg [23:0] AudioL1=0;
	 reg [23:0] AudioR1=0;
	 
	 reg SPDIF1=0;
	 reg SPDIF2=0;
	 reg [11:0] freqcounter=0;
	 reg [5:0] timecounter=1;
	 reg [3:0] timereg=0;
	 reg [1:0] BMC0=0;
	 reg [1:0] BMC1=0;
	 reg [1:0] BMC2=0;
	 reg [1:0] BMC3=0;
	 reg [1:0] BMC4=0;
	 reg [6:0] countbits=0;
	 reg [1:0] syncreg=0;
	 reg [27:0] bufdat=0;
	 wire [1:0] synccodew;
	 wire [1:0] freqselw;
	 reg [1:0] freqselmax=0;
	 reg [1:0] freqsel=0;
	 reg [23:0] AudioLbuf=0;
	 reg [23:0] AudioRbuf=0;
	 reg [23:0] timeoutdt=0;
	 reg noneSIGNAL=0;
	 
	 assign AudioL=noneSIGNAL?0:AudioL1;
	 assign AudioR=noneSIGNAL?0:AudioR1;

	 /////////////////パルス時間検出部//////////////////////////////////
		always @(posedge clk)begin//パルス時間検出部(pulse time detection)
		SPDIF1<=SPDIFin;//メタステ対策
		SPDIF2<=SPDIF1;
		
			if((SPDIF1!=SPDIF2)&&(timecounter>3))begin//変化エッジ検出(changing edge detection )
			noneSIGNAL=0;
				edgeclk=0;//変化ごとのクロック(changing edge clock )
			timereg<= (timecounter<6'h3f)?(timecounter>>2):0;
			timecounter<=1;
		end else if(timecounter<6'h3f)timecounter<=timecounter+1;
		else noneSIGNAL=1;
		if(timecounter==2)edgeclk=1;
		
	 end
	 
		////////////////自動周波数検出(auto frequency detection)//////////////////////////////////
	 assign freqselw=timereg[3]?3:(timereg[2]?2:(timereg[1]?1:0));
	 always @(posedge clk)begin//frequency detector	 
		if(freqcounter<12'hfff)freqcounter=freqcounter+1;
		
		if((freqselw>=freqselmax)||freqcounter==12'hfff)begin
			freqselmax<=freqselw;
			freqcounter=0;
		end	
		
		if((freqselw==freqselmax)/*&&(freqselmax!=0)*/)freqsel<=freqselmax;
		//freqsel<=1;//192kHz固定
	 end
	 
		/////////////////時間幅信号をBMCパルス共通信号に変換(convert time width signal to pulse signal)//////////////////////////////////////
	 assign BMCdec=(freqsel==0)?0:(timereg>>(freqsel-1));
	 
		/////////////////サブフレーム切り出し・出力(output subframe)////////////////////////////////////////////////
	 assign synccodew=(BMC3==3)?(BMC2==3?2:(BMC0==3?1:((BMC0==2&&BMC1==1&&BMC2==2)?3:0))):0;//1:B,2:M,3:W,0:Error
	 
	 always @(posedge edgeclk)begin//サブフレーム取り出し
		 BMC0<=BMCdec;
		 BMC1<=BMC0;
		 BMC2<=BMC1;
		 BMC3<=BMC2;
		 BMC4<=BMC3;
		 
		 if(synccodew!=0)begin
			countbits<=3;
			syncreg<=synccodew;
		 end else begin
			countbits<=countbits+BMC3;
		 end
		 
		 if(countbits>8&&countbits[0]==0)begin
			bufdat=bufdat>>1;
			bufdat[27]=BMC4[0];
		 end
		 
		 if(countbits==7'h40)begin//サブフレーム１つ分受信したら出力する。
			parityOK<=~^bufdat;
			Dout<=bufdat;
			synccode<=syncreg;
			clkout<=0;
			if(parityOK)timeoutdt<=0;
			else timeoutdt<=timeoutdt+1;
			if(timeoutdt<192000)begin
				if((synccode==1)||(synccode==2))begin//フレームごとにL／R同時に更新
					AudioL1<=AudioLbuf;
					AudioR1<=AudioRbuf;
					if(parityOK)AudioLbuf<=Dout&24'hffffff;
					Audioclk<=0;
				end
				if(synccode==3)begin
					Audioclk<=1;
					if(parityOK)AudioRbuf<=Dout&24'hffffff;//Rのサブフレーム検出
				end
			end else begin
				AudioL1<=0;
				AudioR1<=0;
				AudioLbuf<=0;
				AudioRbuf<=0;
			end
			
		 end
		 
		 if(countbits==7'h20)clkout<=1;	 
		 
	 end


endmodule
