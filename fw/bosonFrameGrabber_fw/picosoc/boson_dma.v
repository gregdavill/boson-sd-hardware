  always @(posedge clk) begin
		if(!resetn) begin
			write_jk <= 0;
			write_address <= 0;
			boson_active <= 0;
			wr_d <= 0;
			state <= 0;
			wr_req_boson <= 0;
		end else begin
			if(!write_jk && !CAM_CMOS_VSYNC) begin
				boson_active <= 1;
				write_jk <= 1;
			end

			boson_req <= 0;
			wr_req_boson <= 0;

			/* Pull data out off the FIFO into RAM */
			if(boson_active && boson_rdy) begin
				if(state == 0) begin
                    if(!busy) begin
					    wr_d[31:16] <= boson_d;
					    boson_req <= 1;
                        state <= 1;
                    end
				end
                /* 1 */
				/* 2 */
				else if(state == 3) begin
                    if(!busy) begin
					boson_req <= 1;
					wr_req_boson <= 1;
                    write_address <= write_address + 1;
					wr_d[15:0] <= boson_d;
					state <= 4;
                    end
				end 
				/* 4 */
				/* 5 */
				else if(state == 6) begin
                        wr_d[31:16] <= boson_d;
					    boson_req <= 1;
                        state <= 7;
				end
                /* 7 */
				/* 8 */
				else if(state == 9) begin
					if(busy) begin
                        if(burst_wr_rdy) begin
                            boson_req <= 1;
                            wr_req_boson <= 1;
                            write_address <= write_address + 1;
                            wr_d[15:0] <=  boson_d;
                            state <= 10;
                        end
                    end else begin
                        state <= 3;

                    end
				end
				/* 10 */
				/* 11 */
				else if(state == 12) begin
                        wr_d[31:16] <= boson_d;
					    boson_req <= 1;
                        state <= 13;
				end
                /* 13 */
				/* 14 */
				else if(state == 15) begin
					if(busy) begin
                        if(burst_wr_rdy) begin
                            boson_req <= 1;
                            wr_req_boson <= 1;
                            write_address <= write_address + 1;
                            wr_d[15:0] <=  boson_d;
                            state <= 16;
                        end
                    end else begin
                        state <= 3;

                    end
				end 

				/* 16 */
				/* 17 */
				else if(state == 18) begin
                        wr_d[31:16] <= boson_d;
					    boson_req <= 1;
                        state <= 13;
				end
                /* 19 */
				/* 20 */
				else if(state == 21) begin
					if(busy) begin
                        if(burst_wr_rdy) begin
                            boson_req <= 1;
                            wr_req_boson <= 1;
                            write_address <= write_address + 1;
                            wr_d[15:0] <=  boson_d;
                            state <= 0;
                        end
                    end else begin
                        state <= 3;

                    end
				end 
				
			
				else begin
					state <= state + 1;
                end

				/* 1 Frame */
				if(write_address >= (256*320)) begin
					boson_active <= 0;
					write_jk <= 0;
				end
			end

		end
	end
