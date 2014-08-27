module reg_write(
	input	logic	clk,
	input	logic	rst,
	input	logic	[23:0] data,
	input	logic	d_valid,
	output	logic	st_cp,
	output	logic	sh_cp,
	output	logic	d
);
	
	
	logic	[23:0] data_int;
	logic	sh_cp_int;
	logic	cnt_en;
	logic	[5:0] cnt;
	logic	done;
	
	assign d = data_int[23];
	assign sh_cp = sh_cp_int;
	
	
	//////////////////////////////////////////////////////////////////////////////
	// Internal register for storing and shifting the data
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			data_int <= '0;
		end else
		begin
			if(d_valid)
			begin
				data_int <= data;
			end
			else if(sh_cp_int)
			begin
				data_int <= {data_int[22:0], 1'b0};
			end
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////////////////////
	// Clock for shifting the data through the external registers
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			sh_cp_int <= 1'b0;
		end else if(cnt_en)
		begin
			sh_cp_int <= ~sh_cp_int;
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////////////////////
	// Counter that control the number of bits shifted
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			cnt_en <= 1'b0;
			cnt <= '0;
			done <= 1'b0;
		end else
		begin
			if(d_valid)
			begin
				cnt_en <= 1'b1;
			end else if(done)
			begin
				cnt_en <= 1'b0;
			end
			
			if(cnt_en && !done)
			begin
				cnt <= cnt + 1;
			end else
			begin
				cnt <= '0;
			end
			
			if(!cnt_en)
			begin
				done <= 1'b0;
			end else if(cnt == 46)
			begin
				done <= 1'b1;
			end
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
	
	//////////////////////////////////////////////////////////////////////////////
	// Clock for latching the data in the external shift register to the ouputs
	//////////////////////////////////////////////////////////////////////////////
	always_ff @(posedge clk)
	begin
		if(rst)
		begin
			st_cp <= 1'b0;
		end else
		begin
			if(!cnt_en && done)
			begin
				st_cp <= 1'b1;
			end else
			begin
				st_cp <= 1'b0;
			end
			
		end
	end
	//////////////////////////////////////////////////////////////////////////////
	
	
endmodule
