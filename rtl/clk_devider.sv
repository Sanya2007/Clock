module clk_devider(
	input	logic	clk,
	input	logic	rst,
	output	logic	clk_1M
);

	logic	[4:0] cnt;

	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			cnt <= 0;
			clk_1M <= 1'b0;
		end else
		begin
			if(cnt == 24)
			begin
				clk_1M <= ~clk_1M;
				cnt <= 0;
			end else
			begin
				cnt <= cnt + 1;
			end
		end
	end

endmodule

