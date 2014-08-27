module reg_write
(
	input	logic			i_CLK	,
	input	logic			i_RST	,
	input	logic	[23:0]	i_DATA	,
	input	logic			i_VALID	,
	output	logic			o_ST_CP	,
	output	logic			o_SH_CP	,
	output	logic			o_DATA	
);
	
	
	logic	[23:0]	data;
	logic			valid_del;
	logic			sh_cp_en;
	logic			st_cp_en;
	logic	[5:0]	cnt;
	
	assign o_DATA = data[23];
	assign o_SH_CP = cnt[0];

	//////////////////////////////////////////////////////////////////////////////
	// Internal register for storing and shifting the data
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge i_CLK)
		begin
			if(i_RST)
				begin
					data <= '0;
					valid_del <= 1'b0;
					sh_cp_en <= 1'b0;
					st_cp_en <= 1'b0;
				end
			else
				begin
					valid_del <= i_VALID;
					if((i_VALID ^ valid_del) && !i_VALID)
						begin
							sh_cp_en <= 1'b1;
						end
					else if(cnt[5:1] == 23 && cnt[0])
						begin
							sh_cp_en <= 0;
						end
					
					if(i_VALID)
						begin
							data <= i_DATA;
						end
					else if(sh_cp_en && cnt[0])
						begin
							data <= data << 1;
						end
					
					if(st_cp_en && cnt[5:1] == 24)
						begin
							o_ST_CP <= 1'b1;
						end
					else
						begin
							o_ST_CP <= 1'b0;
						end

					if(i_VALID)
						begin
							st_cp_en <= 1'b1;
						end
					else if(cnt[5:1] == 24)
						begin
							st_cp_en <= 1'b0;							
						end
				end
		end
	//////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////////////////////
	// Counter that control the number of bits shifted
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge i_CLK)
		begin
			if(i_RST || i_VALID)
				begin
					cnt <= '0;
				end
			else if(sh_cp_en) 
				begin
					cnt <= cnt + 1;
				end
		end
	//////////////////////////////////////////////////////////////////////////////
	
endmodule
