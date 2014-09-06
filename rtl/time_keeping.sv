module time_keeping(
	input	logic			i_CLK		,
	input	logic			i_RST		,
	input	logic			i_SET		,
	input	logic			i_HR_INCR	,
	input	logic			i_MN_INCR	,
	output	logic	[3:0]	o_HR_U		,
	output	logic	[1:0]	o_HR_T		,
	output	logic	[3:0]	o_MN_U		,
	output	logic	[2:0]	o_MN_T		,
	output	logic			o_SEC		,
	output	logic			o_SET		,
	output	logic			o_VALID		

);
	
	localparam C_USEC_CNT_LIM = 999; //999

	logic  [9:0]	cnt_usec	;
	logic  [9:0]	usec		;
	logic  [5:0]	sec			;
	logic  [3:0]	hr_u		;
	logic  [1:0]	hr_t		;
	logic  [3:0]	mn_u		;
	logic  [2:0]	mn_t		;
	logic  hr_incr_del;
	logic  mn_incr_del;


	assign o_HR_U = hr_u;
	assign o_HR_T = hr_t;
	assign o_MN_U = mn_u;
	assign o_MN_T = mn_t;

	
	always_ff @(posedge i_CLK)
		begin
			hr_incr_del <= i_HR_INCR;
			mn_incr_del <= i_MN_INCR;
		end
	
	assign hr_incr = (!hr_incr_del && i_HR_INCR && i_SET);
	assign mn_incr = (!mn_incr_del && i_MN_INCR && i_SET);

	always_ff @(posedge i_CLK)
		begin
			if(i_RST || i_SET)
				begin
					cnt_usec <= 0;
					usec <= 0;
					sec <= 0;
					o_VALID <= 1'b0;
					o_SEC <= 1'b0;
				end
			else
				begin
					if(cnt_usec == C_USEC_CNT_LIM)
						begin
							o_VALID <= 1'b1;
							cnt_usec <= 0;
							if(usec == 999)
								begin
									o_SEC <= 1'b1;
									usec <= 0;
									if(sec == 59)
										begin
											sec <= 0;
										end
									else
										begin
											sec <= sec + 1;
										end
								end
							else
								begin
									usec <= usec + 1;
								end
						end
					else
						begin
							cnt_usec <= cnt_usec + 1;
							o_VALID <= 1'b0;
							o_SEC <= 1'b0;
						end
				end
		end

	always_ff @(posedge i_CLK)
		begin
			if(i_RST)
				begin
					mn_u <= 0;
					mn_t <= 0;
					hr_u <= 0;
					hr_t <= 0;
				end
			else
				begin
					if((cnt_usec == C_USEC_CNT_LIM && usec == 999 && sec == 59) || mn_incr)
						begin
							if(mn_u == 9)
								begin
									mn_u <= 0;
									if(mn_t == 5)
										begin
											mn_t <= 0;
										end
									else
										begin
											mn_t <= mn_t + 1;
										end
								end
							else
								begin
									mn_u <= mn_u + 1;
								end
						end
				end

				if((cnt_usec == C_USEC_CNT_LIM && usec == 999 && sec == 59 && mn_u == 9 && mn_t == 5) || hr_incr)
					begin
						if(hr_u == 9 || (hr_u == 3 && hr_t == 2)) 
							begin
								hr_u <= 0;
								if(hr_t == 2)
									begin
										hr_t <= 0;
									end
								else
									begin
										hr_t <= hr_t + 1;
									end
							end
						else
							begin
								hr_u <= hr_u + 1;
							end
				  end
		end
	
endmodule
