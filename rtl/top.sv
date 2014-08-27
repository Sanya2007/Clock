module top(
	input	logic	clk,
	input	logic	rst_n,
	output	logic	st_cp,
	output	logic	sh_cp,
	output	logic	d
);
	
	logic	rst;
	logic	clk_1M;
	logic	[3:0] hour_units;
	logic	[1:0] hour_tens;
	logic	[3:0] min_units;
	logic	[2:0] min_tens;
	logic	sec_en;
	logic	clk_slow;
	logic	[23:0] data;
	logic	d_valid;
	
	
	assign rst = ~rst_n;
	
	
	clk_devider clk_devider_inst(
		.clk(clk),
		.rst(rst),
		.clk_1M(clk_1M)
	);
	
	time_keeping time_keeping_inst(
		.clk(clk_1M),
		.rst(rst),
		.clk_slow(clk_slow),
		.hour_units(hour_units),
		.hour_tens(hour_tens),
		.min_units(min_units),
		.min_tens(min_tens),
		.sec_en(sec_en)
	);
	
	decoder decoder_inst(
		.clk(clk_1M),
		.rst(rst),
		.clk_slow(clk_slow),
		.hour_units(hour_units),
		.hour_tens(hour_tens),
		.min_units(min_units),
		.min_tens(min_tens),
		.sec_en(sec_en),
		.data(data),
		.d_valid(d_valid)
	);
	
	reg_write reg_write_inst(
		.clk(clk_1M),
		.rst(rst),
		.data(data),
		.d_valid(d_valid),
		.st_cp(st_cp),
		.sh_cp(sh_cp),
		.d(d)
	);

endmodule
