module decoder
(
	input	logic			i_CLK		,
	input	logic			i_RST		,
	input	logic			i_VALID		,

	input	logic			i_SET		,
	input	logic	[3:0]	i_HR_U		,
	input	logic	[1:0]	i_HR_T		,
	input	logic	[3:0]	i_MN_U		,
	input	logic	[2:0]	i_MN_T		,
	input	logic			i_SEC		,

	output	logic	[23:0]	o_DATA		,
	output	logic			o_VALID		
);
	
	localparam	C_7S_ZERO	= 8'b0001_1000;
	localparam	C_7S_ONE	= 8'b0111_1011;
	localparam	C_7S_TWO	= 8'b0010_1100;
	localparam	C_7S_THREE	= 8'b0010_1001;
	localparam	C_7S_FOUR	= 8'b0100_1011;
	localparam	C_7S_FIVE	= 8'b1000_1001;
	localparam	C_7S_SIX	= 8'b1000_1000;
	localparam	C_7S_SEVEN	= 8'b0011_1011;
	localparam	C_7S_EIGHT	= 8'b0000_1000;
	localparam	C_7S_NINE	= 8'b0000_1001;
	localparam	C_7S_BLANK	= 8'b1111_1111;
	
	logic	[7:0]	hour_units;
	logic	[7:0]	hour_tens;
	logic	[7:0]	min_units;
	logic	[7:0]	min_tens;
	logic			valid_int;
	logic	[7:0]	led_reg;
	logic	[7:0]	digit_reg;
	logic	[7:0]	sel_reg;
	logic	[7:0]	row_led_on;
	logic	[7:0]	col_led_on;
	logic			led_on;
	logic	[7:0]	curr_led;
	logic	[5:0]	cnt;

	
	
	
	//////////////////////////////////////////////////////////////////////////////
	//
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge i_CLK)
		begin
			if(i_RST)
				begin
					valid_int <= 1'b0;
					o_VALID <= 1'b0;
				end
			else
				begin
					valid_int <= i_VALID;
					o_VALID <= valid_int;
				end
		end
	//////////////////////////////////////////////////////////////////////////////
	
	always_ff @(posedge i_CLK)
		begin
			if(i_RST)
				begin
					o_DATA <= 0;
				end
			else if(valid_int)
				begin
					o_DATA[7:0] <= led_reg;
					o_DATA[15:8] <= digit_reg;
					o_DATA[23:16] <= sel_reg;
				end
		end

	//////////////////////////////////////////////////////////////////////////////
	// Select current 7S digit and row of LEDs
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge i_CLK)
		begin
			if(i_RST)
				begin
					sel_reg <= 8'd1;
				end
			else if(i_VALID)
				begin
					sel_reg <= {sel_reg[6:0], sel_reg[7]};
				end
		end
	//////////////////////////////////////////////////////////////////////////////
	

	//////////////////////////////////////////////////////////////////////////////
	// LED select register
	//////////////////////////////////////////////////////////////////////////////
	always_comb
		begin
			led_on = |(curr_led & sel_reg);
			foreach(led_reg[i])
				begin
					led_reg[i] = ~(row_led_on[i] | (col_led_on[i] & led_on));
				end
		end
	//////////////////////////////////////////////////////////////////////////////
	
	always_ff @(posedge i_CLK)
		begin
			if(i_RST || i_SET)
				begin
					cnt <= 0;
					row_led_on <= 0;
					col_led_on <= 1;
					curr_led <= 1;
				end
			else if(i_VALID && i_SEC)
				begin
					if(cnt == 59)
						begin
							row_led_on <= 0;
							curr_led <= 1;
							col_led_on <= 1;
							cnt <= 0;
						end
					else 
						begin
							cnt <= cnt + 1;
							if(cnt[2:0] == 7)
								begin
									row_led_on <= {row_led_on[6:0], 1'b1};
									col_led_on <= col_led_on << 1;
									curr_led <= 1;
								end
							else
								begin
									curr_led <= {curr_led[6:0], 1'b1};
								end
						end
				end
		end
	

	//////////////////////////////////////////////////////////////////////////////
	// Minute tens into 7-segment display convertion
	//////////////////////////////////////////////////////////////////////////////
	always_comb
		begin
			unique case(i_MN_T)
				3'd0: min_tens = C_7S_ZERO;
				3'd1: min_tens = C_7S_ONE;
				3'd2: min_tens = C_7S_TWO;
				3'd3: min_tens = C_7S_THREE;
				3'd4: min_tens = C_7S_FOUR;
				default: min_tens = C_7S_FIVE;
			endcase
			
			unique case(i_MN_U)
				4'd0: min_units = C_7S_ZERO;
				4'd1: min_units = C_7S_ONE;
				4'd2: min_units = C_7S_TWO;
				4'd3: min_units = C_7S_THREE;
				4'd4: min_units = C_7S_FOUR;
				4'd5: min_units = C_7S_FIVE;
				4'd6: min_units = C_7S_SIX;
				4'd7: min_units = C_7S_SEVEN;
				4'd8: min_units = C_7S_EIGHT;
				default: min_units = C_7S_NINE;
			endcase
					
			unique case(i_HR_T)
				3'd0: hour_tens = C_7S_BLANK;
				3'd1: hour_tens = C_7S_ONE;
				default: hour_tens = C_7S_TWO;
			endcase
		
			unique case(i_HR_U)
				4'd0: hour_units = C_7S_ZERO;
				4'd1: hour_units = C_7S_ONE;
				4'd2: hour_units = C_7S_TWO;
				4'd3: hour_units = C_7S_THREE;
				4'd4: hour_units = C_7S_FOUR;
				4'd5: hour_units = C_7S_FIVE;
				4'd6: hour_units = C_7S_SIX;
				4'd7: hour_units = C_7S_SEVEN;
				4'd8: hour_units = C_7S_EIGHT;
				default: hour_units = C_7S_NINE;
			endcase

			unique case(sel_reg)
				8'd16: digit_reg = hour_tens;
				8'd32: digit_reg = hour_units;
				8'd64: digit_reg = min_tens;
				default: digit_reg = min_units;
			endcase
		end
	//////////////////////////////////////////////////////////////////////////////
	
endmodule
