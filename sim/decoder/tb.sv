module tb;

	logic			i_CLK = 0	;
	logic			i_RST = 0	;
	logic			i_VALID		;
	
	logic			i_SET = 0	;
	logic	[3:0]	i_HR_U = 0	;
	logic	[1:0]	i_HR_T = 0	;
	logic	[3:0]	i_MN_U = 0	;
	logic	[2:0]	i_MN_T = 0	;
	logic			i_SEC		;
	
	logic	[23:0]	o_DATA		;
	logic			o_VALID		;
	
	localparam C_VALID_PER = 10;
	localparam C_SEC_PER = 10 * C_VALID_PER;

	int sec_cnt = 0;
	int valid_cnt = 0;
	

	decoder decoder_inst(.*);

	always
		#5 i_CLK = ~i_CLK;
	
	initial
		begin
			#15 i_RST = 1;
			#30 i_RST = 0;
			#1000 i_SET = 1;
			#2000 i_SET = 0;
		end
	

	always @(posedge i_CLK)
		if(i_RST)
			begin
				i_SEC <= 1'b0;
				i_VALID <= 1'b0;
				sec_cnt <= 0;
				valid_cnt <= 0;
			end
		else
			begin
				if(sec_cnt == C_SEC_PER - 1)
					begin
						sec_cnt <= 0;
						i_SEC <= 1'b1;
						
						i_HR_U <= $urandom_range(9);
						i_HR_T <= $urandom_range(2);
						i_MN_U <= $urandom_range(9);
						i_MN_T <= $urandom_range(5);
					end
				else
					begin
						sec_cnt <= sec_cnt + 1;
						i_SEC <= 1'b0;
					end
				
				if(valid_cnt == C_VALID_PER - 1)
					begin
						valid_cnt <= 0;
						i_VALID <= 1'b1;
					end
				else
					begin
						valid_cnt <= valid_cnt + 1;
						i_VALID <= 1'b0;
					end
			end


endmodule
