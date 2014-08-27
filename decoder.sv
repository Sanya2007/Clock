module decoder(
	input	logic	clk,
	input	logic	rst,
	input	logic	clk_slow,
	input	logic	[3:0] hour_units,
	input	logic	[1:0] hour_tens,
	input	logic	[3:0] min_units,
	input	logic	[2:0] min_tens,
	input	logic	sec_en,
	output	logic	[23:0] data,
	output	logic	d_valid
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
	
	logic	[7:0] hour_units_reg;
	logic	[7:0] hour_tens_reg;
	logic	[7:0] min_units_reg;
	logic	[7:0] min_tens_reg;
	logic	[7:0] [7:0] sec_reg;
	
	logic	[7:0] sel_reg;
	logic	[2:0][7:0] data_int;
	logic	sel_en;
	logic	data_en;
	logic	clk_slow_del;
	
	
	//////////////////////////////////////////////////////////////////////////////
	//
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			clk_slow_del <= 1'b0;
			sel_en <= 1'b0;
			data_en <= 1'b0;
			d_valid <= 1'b0;
		end else
		begin
			clk_slow_del <= clk_slow;
			
			if(!clk_slow && clk_slow_del)
			begin
				sel_en <= 1'b1;
			end else
			begin
				sel_en <= 1'b0;
			end
			
			data_en <= sel_en;
			d_valid <= data_en;
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////////////////////
	//
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			data <= '0;
		end else if(data_en)
		begin
			data <= data_int;
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////////////////////
	//
	//////////////////////////////////////////////////////////////////////////////
	always_comb
	begin
		case(sel_reg)
			8'd1:
			begin
				data_int[0] = {sec_reg[7][0], sec_reg[6][0], sec_reg[5][0], sec_reg[4][0], sec_reg[3][0], sec_reg[2][0], sec_reg[1][0], sec_reg[0][0]};
				data_int[1] = '1;
			end
			8'd2:
			begin
				data_int[0] = {sec_reg[7][1], sec_reg[6][1], sec_reg[5][1], sec_reg[4][1], sec_reg[3][1], sec_reg[2][1], sec_reg[1][1], sec_reg[0][1]};
				data_int[1] = '1;
			end
			8'd4:
			begin
				data_int[0] = {sec_reg[7][2], sec_reg[6][2], sec_reg[5][2], sec_reg[4][2], sec_reg[3][2], sec_reg[2][2], sec_reg[1][2], sec_reg[0][2]};
				data_int[1] = '1;
			end
			8'd8:
			begin
				data_int[0] = {sec_reg[7][3], sec_reg[6][3], sec_reg[5][3], sec_reg[4][3], sec_reg[3][3], sec_reg[2][3], sec_reg[1][3], sec_reg[0][3]};
				data_int[1] = '1;
			end
			8'd16:
			begin
				data_int[0] = {sec_reg[7][4], sec_reg[6][4], sec_reg[5][4], sec_reg[4][4], sec_reg[3][4], sec_reg[2][4], sec_reg[1][4], sec_reg[0][4]};
				data_int[1] = min_units_reg;
			end
			8'd32:
			begin
				data_int[0] = {sec_reg[7][5], sec_reg[6][5], sec_reg[5][5], sec_reg[4][5], sec_reg[3][5], sec_reg[2][5], sec_reg[1][5], sec_reg[0][5]};
				data_int[1] = min_tens_reg;
			end
			8'd64:
			begin
				data_int[0] = {sec_reg[7][6], sec_reg[6][6], sec_reg[5][6], sec_reg[4][6], sec_reg[3][6], sec_reg[2][6], sec_reg[1][6], sec_reg[0][6]};
				data_int[1] = hour_units_reg;
			end
			8'd128:
			begin
				data_int[0] = {sec_reg[7][7], sec_reg[6][7], sec_reg[5][7], sec_reg[4][7], sec_reg[3][7], sec_reg[2][7], sec_reg[1][7], sec_reg[0][7]};
				data_int[1] = hour_tens_reg;
			end
			default:
			begin
				data_int[0] = '1;
				data_int[1] = '1;
			end
		endcase
		data_int[2] = sel_reg;
	end
	//////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////////////////////
	// Select shift register
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			sel_reg <= 8'd1;
		end else if(sel_en)
		begin
			sel_reg <= {sel_reg[6:0], sel_reg[7]};
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////////////////////
	// Seconds shift register
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			sec_reg <= '0;
		end else if(sec_en)
		begin
			if(sec_en)
			begin
				sec_reg <= 64'd1;
			end else
			begin
				sec_reg <= {sec_reg, 1'b1};
			end
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////////////////////
	// Minutes tens into 7-segment display convertion
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			min_tens_reg <= '0;
		end else if(sec_en)
		begin
			case(min_tens)
				3'd0: min_tens_reg <= C_7S_ZERO;
				3'd1: min_tens_reg <= C_7S_ONE;
				3'd2: min_tens_reg <= C_7S_TWO;
				3'd3: min_tens_reg <= C_7S_THREE;
				3'd4: min_tens_reg <= C_7S_FOUR;
				3'd5: min_tens_reg <= C_7S_FIVE;
				default: min_tens_reg <= C_7S_BLANK;
			endcase
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////////////////////
	// Minutes units into 7-segment display convertion
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			min_units_reg <= '0;
		end else if(sec_en)
		begin
			case(min_units)
				4'd0: min_units_reg <= C_7S_ZERO;
				4'd1: min_units_reg <= C_7S_ONE;
				4'd2: min_units_reg <= C_7S_TWO;
				4'd3: min_units_reg <= C_7S_THREE;
				4'd4: min_units_reg <= C_7S_FOUR;
				4'd5: min_units_reg <= C_7S_FIVE;
				4'd6: min_units_reg <= C_7S_SIX;
				4'd7: min_units_reg <= C_7S_SEVEN;
				4'd8: min_units_reg <= C_7S_EIGHT;
				4'd9: min_units_reg <= C_7S_NINE;
				default: min_units_reg <= C_7S_BLANK;
			endcase
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
	
		//////////////////////////////////////////////////////////////////////////////
	// Minutes tens into 7-segment display convertion
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			hour_tens_reg <= '0;
		end else if(sec_en)
		begin
			case(hour_tens)
				3'd0: hour_tens_reg <= C_7S_BLANK;
				3'd1: hour_tens_reg <= C_7S_ONE;
				3'd2: hour_tens_reg <= C_7S_TWO;
				default: hour_tens_reg <= C_7S_BLANK;
			endcase
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////////////////////
	// Minutes units into 7-segment display convertion
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			hour_units_reg <= '0;
		end else if(sec_en)
		begin
			case(hour_units)
				4'd0: hour_units_reg <= C_7S_ZERO;
				4'd1: hour_units_reg <= C_7S_ONE;
				4'd2: hour_units_reg <= C_7S_TWO;
				4'd3: hour_units_reg <= C_7S_THREE;
				4'd4: hour_units_reg <= C_7S_FOUR;
				4'd5: hour_units_reg <= C_7S_FIVE;
				4'd6: hour_units_reg <= C_7S_SIX;
				4'd7: hour_units_reg <= C_7S_SEVEN;
				4'd8: hour_units_reg <= C_7S_EIGHT;
				4'd9: hour_units_reg <= C_7S_NINE;
				default: hour_units_reg <= C_7S_BLANK;
			endcase
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
endmodule