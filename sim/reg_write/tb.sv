`timescale 1ns / 1ps

module tb;

	logic			i_CLK = 0	;
	logic			i_RST = 0	;
	logic	[23:0]	i_DATA	;
	logic			i_VALID	;
	logic			o_ST_CP	;
	logic			o_SH_CP	;
	logic			o_DATA	;
	
	int cnt = 0;

	always
		#5 i_CLK = ~i_CLK;

	initial
		begin
			#10 i_RST = 1;
			#20 i_RST = 0;
		end

	reg_write DUT(
		.i_CLK(i_CLK),
		.i_RST(i_RST),
		.i_DATA(i_DATA),
		.i_VALID(i_VALID),
		.o_ST_CP(o_ST_CP),
		.o_SH_CP(o_SH_CP),
		.o_DATA(o_DATA)
	);

	always @(posedge i_CLK)
		begin
			if(i_RST)
				begin
					cnt = 0;
					i_DATA <= '0;
				end
			else
				begin
					if(cnt == 100)
						begin
							cnt = 0;
							i_VALID <= 1;
							i_DATA <= $urandom;
							$display("New data\n");
						end
					else
						begin
							cnt++;
							i_VALID <= 0;
						end
				end
		end


endmodule
