module time_keeping(
	input	logic	clk,
	input	logic	rst,
	output	logic	clk_slow,
	output	logic	[3:0] hour_units,
	output	logic	[1:0] hour_tens,
	output	logic	[3:0] min_units,
	output	logic	[2:0] min_tens,
	output	logic	sec_en
);
	
	logic	[9:0] cnt_clk_slow;
	logic	[5:0] cnt_sec;
	logic	[3:0] cnt_min_units;
	logic	[2:0] cnt_min_tens;
	logic	[3:0] cnt_hour_units;
	logic	[1:0] cnt_hour_tens;
	
	
	//////////////////////////////////////////////////////////////////////////////
	//
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			clk_slow <= 1'b0;
			sec_en <= 1'b0;
			cnt_clk_slow <= 0;
			cnt_sec <= 0;
			cnt_min_units <= 0;
			cnt_min_tens <= 0;
			cnt_hour_units <= 0;
			cnt_hour_tens <= 0;
		end else
		begin
			if(cnt_clk_slow == 999)
			begin
				clk_slow <= ~clk_slow;
				cnt_clk_slow <= 0;
				if(cnt_sec == 999)
				begin
					cnt_sec <= 0;
					sec_en <= 1'b1;	
					if(cnt_min_units == 9)
					begin
						cnt_min_units <= 0;
						if(cnt_min_tens == 5)
						begin
							cnt_min_tens <= 0;
							if(hour_units == 9 || (hour_units == 3 && hour_tens == 2))
							begin
								hour_units <= 0;
								if(hour_tens == 2)
								begin
									hour_tens <= 0;
								end else
								begin
									hour_tens <= hour_tens + 1;
								end
							end else
							begin
								hour_units <= hour_units + 1;
							end
						end else
						begin
							cnt_min_tens <= cnt_min_tens + 1;
						end
					end	else
						cnt_min_units <= cnt_min_units + 1;
					begin
						
					end		
				end else
				begin
					sec_en <= 1'b0;
					cnt_sec <= cnt_sec + 1;
				end
			end else
			begin
				cnt_clk_slow <= cnt_clk_slow + 1;
			end
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
endmodule
