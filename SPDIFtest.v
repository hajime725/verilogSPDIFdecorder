`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:40:12 02/27/2018
// Design Name:   SPDIFdecoder
// Module Name:   C:/Users/hajime/Documents/DesignLab/Benchy_Sump_LogicAnalyzer_JTAG/copytest/SPDIFtest.v
// Project Name:  copytest
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SPDIFdecoder
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module SPDIFtest;

	// Inputs
	reg SPDIFin;
	
	reg clk;

	// Outputs
	wire clkout;
	wire [29:0] Dout;
	wire [1:0] synccode;
	wire [1:0] BMCdec;
	wire edgeclock;
	
	
	integer i;
	integer j;
	reg [1:0] dat[128:0];

	// Instantiate the Unit Under Test (UUT)
	SPDIFdecoder uut (
	 .SPDIFin(SPDIFin), 
    .BMCdec(BMCdec), 
    .clk(clk), 
    .edgeclk(edgeclk), 
    .clkout(clkout), 
    .Dout(Dout), 
    .synccode(synccode)
	);
	
		always #5
        clk <= !clk;
		  
	initial begin
		// Initialize Inputs
		SPDIFin = 0;
		//BMCdec = 0;
		clk = 0;
		for(i=0;i<128;i=i+1)dat[i]=2;
		i=0;
		dat[i]=1;
		i=i+1;dat[i]=2;
		i=i+1;dat[i]=1;
		//i=i+1;dat[i]=3;
		//i=i+1;dat[i]=1;
		//i=i+1;dat[i]=1;
		//i=i+1;dat[i]=3;
		i=i+1;dat[i]=3;
		i=i+1;dat[i]=2;
		i=i+1;dat[i]=1;
		i=i+1;dat[i]=2;
		i=i+1;dat[i]=1;
		i=i+1;dat[i]=1;
		i=i+1;dat[i]=2;
		i=i+1;dat[i]=1;
		i=i+1;dat[i]=1;
		
		
		

		// Wait 100 ns for global reset to finish
		#100;
		for(i=0;i<128;i=i+1)begin
		//clk = 0;
			SPDIFin=~SPDIFin;
			for(j=0;j<dat[i];j=j+1)begin
				//#40.69;
				#177.16;
				//#40.69;
				//#40.69;
				//#40.69;
			end
		//#5
		//BMCdec=dat[i];
		//clk=1;
		//#5;
		end

		#5;//11331111->2
		// Add stimulus here

	end
	
	
      
endmodule

