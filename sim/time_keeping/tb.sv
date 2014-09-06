module tb;

	logic			i_CLK=0		;
	logic			i_RST=0		;
	logic			i_SET=0		;
	logic			i_HR_INCR=0	;
	logic			i_MN_INCR=0	;
	logic	[3:0]	o_HR_U		;
	logic	[1:0]	o_HR_T		;
	logic	[3:0]	o_MN_U		;
	logic	[2:0]	o_MN_T		;
	logic	[5:0]	o_SEC		;
	logic	[9:0]	o_USEC		;

	always
		#5 i_CLK = ~i_CLK;

	initial
		begin
			#15 i_RST = 1;
			#20 i_RST = 0;
		end

	time_keeping time_keeping_inst(.*);

endmodule
