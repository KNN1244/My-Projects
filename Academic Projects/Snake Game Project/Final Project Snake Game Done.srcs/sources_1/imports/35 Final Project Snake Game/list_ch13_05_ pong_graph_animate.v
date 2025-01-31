// Listing 13.5
module snake_graph_animate
   (
    input wire clk, reset, start, difficulty, infinite,
    input wire video_on,
    input wire [4:0] btn,
    input wire [9:0] pix_x, pix_y,
    output reg [11:0] graph_rgb,
    output reg [4:0] events
   );

   // constant and signal declaration
   // x, y coordinates (0,0) to (639,479)
   localparam MAX_X = 640;
   localparam MAX_Y = 480;
   wire refr_tick;
   //--------------------------------------------
   // Top wall
   //--------------------------------------------
   localparam WALLT_X_L = 115;
   localparam WALLT_X_R = 525;
   localparam WALLT_Y_T = 35;
   localparam WALLT_Y_B = 40;
   //--------------------------------------------
   // Bottom wall
   //--------------------------------------------
   localparam WALLB_X_L = 115;
   localparam WALLB_X_R = 525;
   localparam WALLB_Y_T = 440;
   localparam WALLB_Y_B = 445;
   //--------------------------------------------
   // Left wall
   //--------------------------------------------
   localparam WALLL_X_L = 115;
   localparam WALLL_X_R = 120;
   localparam WALLL_Y_T = 35;
   localparam WALLL_Y_B = 440;
   //--------------------------------------------
   // Right wall
   //--------------------------------------------
   localparam WALLR_X_L = 520;
   localparam WALLR_X_R = 525;
   localparam WALLR_Y_T = 35;
   localparam WALLR_Y_B = 440;
   //--------------------------------------------
   // Play Area
   //--------------------------------------------
   localparam PLAY_AREA_X_L = WALLL_X_R;
   localparam PLAY_AREA_X_R = WALLR_X_L;
   localparam PLAY_AREA_Y_T = WALLT_Y_B;
   localparam PLAY_AREA_Y_B = WALLB_Y_T;
   //--------------------------------------------
   // snake
   //--------------------------------------------
   localparam SNAKE_P_SIZE = 10; // Number of pixels for snake body
   localparam SNAKE_MAX_SIZE = 1000; // Max number of snake bodies
   reg [10:0] snake_body_no, snake_body_no_next; // The current number of snake bodies
   reg snake_eat_ball, snake_eat_ball_next; // track to see if the snake have eaten the ball
   // Body of snake
   reg [9:0] snake_x_l [SNAKE_MAX_SIZE:0];
   reg [9:0] snake_x_r [SNAKE_MAX_SIZE:0];
   reg [9:0] snake_y_t [SNAKE_MAX_SIZE:0];
   reg [9:0] snake_y_b [SNAKE_MAX_SIZE:0];
   reg [9:0] snake_x_reg [SNAKE_MAX_SIZE:0];
   reg [9:0] snake_y_reg [SNAKE_MAX_SIZE:0];
   reg [9:0] snake_x_next [SNAKE_MAX_SIZE:0];
   reg [9:0] snake_y_next [SNAKE_MAX_SIZE:0];
   // Couters for body
   integer count_reg;
   // game event tracker
   reg [4:0] events_next;
   // registers for snake movement
   reg [9:0] x_delta_reg, x_delta_next;
   reg [9:0] y_delta_reg, y_delta_next;
   reg [3:0] direction, tail_direction;
   localparam SNAKE_V_P = 10;
   localparam SNAKE_V_N = -10;
   //--------------------------------------------
   // square ball
   //--------------------------------------------
   localparam BALL_SIZE = 10;
   // ball left, right boundary
   wire [9:0] ball_x_l, ball_x_r;
   // ball top, bottom boundary
   wire [9:0] ball_y_t, ball_y_b;
   // reg to track left, top position
   reg [9:0] ball_x_reg, ball_y_reg;
   reg [9:0] ball_x_next, ball_y_next;
   // reg to track ball speed
   // ball velocity can be pos or neg)
   //--------------------------------------------
   // round ball
   //--------------------------------------------
   wire [3:0] rom_addr, rom_col;
   reg [9:0] rom_data;
   wire rom_bit;
   //--------------------------------------------
   // dome snake_head
   //--------------------------------------------
   wire [7:0] head_addr;
   wire [3:0] head_col;
   reg [9:0] head_data;
   wire head_bit;
   //--------------------------------------------
   // triangle snake_tail
   //--------------------------------------------
   wire [7:0] tail_addr;
   wire [3:0] tail_col;
   reg [9:0] tail_data;
   wire tail_bit;
   //--------------------------------------------
   // object output signals and event signals
   //--------------------------------------------
   wire wall_on, play_area_on, grid_on, sq_ball_on, rd_ball_on;
   wire reached_wall, snake_on, snake_rom_bit;
   reg square_snake_on, snake_head_on, snake_tail_on;
   reg head_hit_body, head_hit_next, start_up;
   wire [11:0] wall_rgb, play_area_rgb, grid_rgb, snake_rgb, ball_rgb, bg_rgb;
   // Snake speed configuration
   wire snake_Hz, MHz25;
   reg snake_stop;
   snakeClkGen snake_speed(clk, snake_stop, difficulty, snake_Hz);
   // snake growth reg
   wire [3:0] growth;
   assign growth = (difficulty) ? 1: 4;
   // One second timer for eating sound effect
   reg beep_event, reset_event, rule_event;
   SecPulse one_sec_clk(clk, 1'b0, 5'b00001, beep_event ,beep_sec); // half sec
   SecPulse ten_sec_clk(clk, 1'b0, 5'b10100, (rule_event||start_up), rule_sec); // ten sec
   // Half of 50MHz generator
   clk_50m_generator my25MHz(clk, 1'b0, MHz25);
   // Random Number Generator
   wire [5:0] limit, rand_0, rand_1;
   assign limit = 39;
   RandomGen(clk, limit, rand_0, rand_1);
   
   // instantiate the text generator
   wire [3:0] dig0, dig1, dig2, dig3;
   wire [3:0] text_on1, text_on2;
   wire [11:0] text_rgb1, text_rgb2;
   reg [10:0] high_score;
   // Handles logo, win and lose conditions with black background
   pong_text text_unit 
       (.clk(clk), .pix_x(pix_x), .pix_y(pix_y), .bg_rgb(play_area_rgb),
        .text_on(text_on1), .text_rgb(text_rgb1));
   // Handles score and rules with background color passed
   pong_text2 text_unit2
       (.clk(clk), .pix_x(pix_x), .pix_y(pix_y),
       .dig0(dig0), .dig1(dig1), .dig2(dig2), .dig3(dig3),
       .hs_dig0(hs_dig0), .hs_dig1(hs_dig1), .hs_dig2(hs_dig2), .hs_dig3(hs_dig3),
       .bg_rgb(bg_rgb), .text_on(text_on2), .text_rgb(text_rgb2));
   // normal score assignment
   assign dig0 = (snake_body_no-3)%10;
   assign dig1 = (snake_body_no-3)%100/10;
   assign dig2 = (snake_body_no-3)%1000/100;
   assign dig3 = (snake_body_no-3)/1000;
   // high score assignment
   assign hs_dig0 = (high_score-3)%10;
   assign hs_dig1 = (high_score-3)%100/10;
   assign hs_dig2 = (high_score-3)%1000/100;
   assign hs_dig3 = (high_score-3)/1000;

   // body
   //--------------------------------------------
   // round ball image ROM
   //--------------------------------------------
   always @* begin
   case (rom_addr)
      4'h0: rom_data = 10'b0001111000; //    ****
      4'h1: rom_data = 10'b0111111110; //  ********
      4'h2: rom_data = 10'b0111111110; //  ********
      4'h3: rom_data = 10'b1111111111; // **********
      4'h4: rom_data = 10'b1111111111; // **********
      4'h5: rom_data = 10'b1111111111; // **********
      4'h6: rom_data = 10'b1111111111; // **********
      4'h7: rom_data = 10'b0111111110; //  ********
      4'h8: rom_data = 10'b0111111110; //  ********
      4'h9: rom_data = 10'b0001111000; //    ****
   endcase
   case (head_addr)
        // Snake head right
        8'h00: head_data = 10'b1111000000;
        8'h01: head_data = 10'b1111110000;
        8'h02: head_data = 10'b1111111100;
        8'h03: head_data = 10'b1111001111;
        8'h04: head_data = 10'b1111111111;
        8'h05: head_data = 10'b1111111111;
        8'h06: head_data = 10'b1111001111;
        8'h07: head_data = 10'b1111111100;
        8'h08: head_data = 10'b1111110000;
        8'h09: head_data = 10'b1111000000;
        
        // Snake head left
        8'h10: head_data = 10'b0000001111;
        8'h11: head_data = 10'b0000111111;
        8'h12: head_data = 10'b0011111111;
        8'h13: head_data = 10'b1111001111;
        8'h14: head_data = 10'b1111111111;
        8'h15: head_data = 10'b1111111111;
        8'h16: head_data = 10'b1111001111;
        8'h17: head_data = 10'b0011111111;
        8'h18: head_data = 10'b0000111111;
        8'h19: head_data = 10'b0000001111;
        
        // Snake head up
        8'h20: head_data = 10'b0001111000;
        8'h21: head_data = 10'b0001111000;
        8'h22: head_data = 10'b0011111100;
        8'h23: head_data = 10'b0011111100;
        8'h24: head_data = 10'b0110110110;
        8'h25: head_data = 10'b0110110110;
        8'h26: head_data = 10'b1111111111;
        8'h27: head_data = 10'b1111111111;
        8'h28: head_data = 10'b1111111111;
        8'h29: head_data = 10'b1111111111;
        
        // Snake head down
        8'h30: head_data = 10'b1111111111;
        8'h31: head_data = 10'b1111111111;
        8'h32: head_data = 10'b1111111111;
        8'h33: head_data = 10'b1111111111;
        8'h34: head_data = 10'b0110110110;
        8'h35: head_data = 10'b0110110110;
        8'h36: head_data = 10'b0011111100;
        8'h37: head_data = 10'b0011111100;
        8'h38: head_data = 10'b0001111000;
        8'h39: head_data = 10'b0001111000;

   endcase
   case (tail_addr)
        // Snake tail right
        8'h00: tail_data = 10'b0000000001;
        8'h01: tail_data = 10'b0000000111;
        8'h02: tail_data = 10'b0000011111;
        8'h03: tail_data = 10'b0001111111;
        8'h04: tail_data = 10'b1111111111;
        8'h05: tail_data = 10'b1111111111;
        8'h06: tail_data = 10'b0001111111;
        8'h07: tail_data = 10'b0000011111;
        8'h08: tail_data = 10'b0000000111;
        8'h09: tail_data = 10'b0000000001;
        
        // Snake tail left
        8'h10: tail_data = 10'b1000000000;
        8'h11: tail_data = 10'b1110000000;
        8'h12: tail_data = 10'b1111100000;
        8'h13: tail_data = 10'b1111111000;
        8'h14: tail_data = 10'b1111111111;
        8'h15: tail_data = 10'b1111111111;
        8'h16: tail_data = 10'b1111111000;
        8'h17: tail_data = 10'b1111100000;
        8'h18: tail_data = 10'b1110000000;
        8'h19: tail_data = 10'b1000000000;
        
        // Snake tail up
        8'h20: tail_data = 10'b1111111111;
        8'h21: tail_data = 10'b0111111110;
        8'h22: tail_data = 10'b0111111110;
        8'h23: tail_data = 10'b0011111100;
        8'h24: tail_data = 10'b0011111100;
        8'h25: tail_data = 10'b0001111000;
        8'h26: tail_data = 10'b0001111000;
        8'h27: tail_data = 10'b0000110000;
        8'h28: tail_data = 10'b0000110000;
        8'h29: tail_data = 10'b0000110000;
        
        // Snake tail down
        8'h30: tail_data = 10'b0000110000;
        8'h31: tail_data = 10'b0000110000;
        8'h32: tail_data = 10'b0000110000;
        8'h33: tail_data = 10'b0001111000;
        8'h34: tail_data = 10'b0001111000;
        8'h35: tail_data = 10'b0011111100;
        8'h36: tail_data = 10'b0011111100;
        8'h37: tail_data = 10'b0111111110;
        8'h38: tail_data = 10'b0111111110;
        8'h39: tail_data = 10'b1111111111;   
          
   endcase
   end
   
   initial begin
   snake_x_next[0] <= 320;
   snake_y_next[0] <= 240;
   snake_body_no_next <= 3;
   ball_x_next <= 240;
   ball_y_next <= 320;
   events_next <= 5'b00000;
   start_up <= 1;
   high_score <= 0;
   end
   
   // registers
   always @(posedge clk, posedge btn[4])
      if (btn[4])
         begin
            ball_x_reg <= 240;
            ball_y_reg <= 320;
            x_delta_reg <= 0;
            y_delta_reg <= 0;
            events <= 5'b00001;
            head_hit_body <= 0;
            snake_body_no <= 3;
            snake_eat_ball <= 0;
            for (count_reg = 0; count_reg < SNAKE_MAX_SIZE; count_reg = count_reg + 1) begin
                if (count_reg < snake_body_no)
                begin
                    snake_x_reg [count_reg] <= 320;
                    snake_y_reg [count_reg] <= 240;
                end
                else
                begin
                    snake_x_reg [count_reg] <= 0;
                    snake_y_reg [count_reg] <= 0;
                end
            end
         end
      else
         begin
            ball_x_reg <= ball_x_next;
            ball_y_reg <= ball_y_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
            events <= events_next;
            snake_body_no <= snake_body_no_next;
            head_hit_body <= head_hit_next;
            snake_eat_ball <= snake_eat_ball_next;
            for (count_reg = 0; count_reg < SNAKE_MAX_SIZE; count_reg = count_reg + 1) begin
                if (count_reg < snake_body_no)
                begin
                    snake_x_reg [count_reg] <= snake_x_next [count_reg];
                    snake_y_reg [count_reg] <= snake_y_next [count_reg];
                end
            end
         end

   // refr_tick: 1-clock tick asserted at start of v-sync
   //            i.e., when the screen is refreshed (60 Hz)
   assign refr_tick = (pix_y==481) && (pix_x==0);
   //--------------------------------------------
   // Four walls
   //--------------------------------------------
   // pixel within wall
   assign wall_on = ((WALLT_X_L<=pix_x) && (pix_x<=WALLT_X_R) && (WALLT_Y_T<=pix_y) && (pix_y<=WALLT_Y_B)) ||// Top Wall
   ((WALLB_X_L<=pix_x) && (pix_x<=WALLB_X_R) && (WALLB_Y_T<=pix_y) && (pix_y<=WALLB_Y_B)) || // Bottom Wall
   ((WALLL_X_L<=pix_x) && (pix_x<=WALLL_X_R) && (WALLL_Y_T<=pix_y) && (pix_y<=WALLL_Y_B)) || // Left Wall
   ((WALLR_X_L<=pix_x) && (pix_x<=WALLR_X_R) && (WALLR_Y_T<=pix_y) && (pix_y<=WALLR_Y_B)); // Right Wall
   // wall rgb output
   assign wall_rgb = 12'b000100011111; // light blue
   //--------------------------------------------
   // Play Area
   //--------------------------------------------
   // pixel within play area
   assign play_area_on = (PLAY_AREA_X_L<=pix_x) && (pix_x<=PLAY_AREA_X_R) && (PLAY_AREA_Y_T<=pix_y) && (pix_y<=PLAY_AREA_Y_B);
   // play area rgb output
   assign play_area_rgb = 12'b000000000000; // black
   //--------------------------------------------
   // Grid 
   //--------------------------------------------
   // pixel within grids
   assign grid_on = play_area_on && 
   ((pix_x==120)||(pix_x==130)||(pix_x==140)||(pix_x==150)||(pix_x==160)||(pix_x==170)||(pix_x==180)||(pix_x==190)||
   (pix_x==200)||(pix_x==210)||(pix_x==220)||(pix_x==230)||(pix_x==240)||(pix_x==250)||(pix_x==260)||(pix_x==270)||
   (pix_x==280)||(pix_x==290)||(pix_x==300)||(pix_x==310)||(pix_x==320)||(pix_x==330)||(pix_x==340)||(pix_x==350)||
   (pix_x==360)||(pix_x==370)||(pix_x==380)||(pix_x==390)||(pix_x==400)||(pix_x==410)||(pix_x==420)||(pix_x==430)||
   (pix_x==440)||(pix_x==450)||(pix_x==460)||(pix_x==470)||(pix_x==480)||(pix_x==490)||(pix_x==500)||(pix_x==510)||
   (pix_x==520) ||
   (pix_y==40)||(pix_y==50)||(pix_y==60)||(pix_y==70)||(pix_y==80)||(pix_y==90)||(pix_y==100)||(pix_y==110)||
   (pix_y==120)||(pix_y==130)||(pix_y==140)||(pix_y==150)||(pix_y==160)||(pix_y==170)||(pix_y==180)||(pix_y==190)||
   (pix_y==200)||(pix_y==210)||(pix_y==220)||(pix_y==230)||(pix_y==240)||(pix_y==250)||(pix_y==260)||(pix_y==270)||
   (pix_y==280)||(pix_y==290)||(pix_y==300)||(pix_y==310)||(pix_y==320)||(pix_y==330)||(pix_y==340)||(pix_y==350)||
   (pix_y==360)||(pix_y==370)||(pix_y==380)||(pix_y==390)||(pix_y==400)||(pix_y==410)||(pix_y==420)||(pix_y==430)||
   (pix_y==440)) 
;
   assign grid_rgb = 12'b000100010001; // dark gray
   //--------------------------------------------
   // Snake body
   //--------------------------------------------
   // boundary
   always@*
   begin
        for(count_reg = 0; count_reg < SNAKE_MAX_SIZE; count_reg = count_reg + 1)
		begin
			if(count_reg < snake_body_no)
			begin				
				 snake_x_l[count_reg] = snake_x_reg[count_reg];
				 snake_x_r[count_reg] = snake_x_l[count_reg] + SNAKE_P_SIZE -1;
				 snake_y_t[count_reg] = snake_y_reg[count_reg];
				 snake_y_b[count_reg] = snake_y_t[count_reg] + SNAKE_P_SIZE -1;
			end
		end
   end
   // pixel within bar

   // bar rgb output
   assign snake_rgb = 12'b000011110000; // green
   
   always@(posedge snake_Hz)
	begin
	snake_body_no_next = snake_body_no;
	ball_x_next = ball_x_reg;
	ball_y_next = ball_y_reg;
	   // Handles snake and ball collision
	    if ((snake_x_reg[0] == ball_x_reg)&&(snake_y_reg[0] == ball_y_reg)) begin
            snake_body_no_next = snake_body_no + growth;
            snake_eat_ball_next = 1; // used for apple gen
        end
        // Generates a new position for ball
		if (snake_eat_ball == 1) begin
		   ball_x_next = (rand_0 * 10)+120;
	       ball_y_next = (rand_1 * 10)+40;
	    end
	    for(count_reg = 0; count_reg < SNAKE_MAX_SIZE; count_reg = count_reg + 1)
		   begin
		   if (count_reg < snake_body_no) begin
		       if ((ball_x_next == snake_x_reg[count_reg])&&(ball_y_next == snake_y_reg[count_reg])) begin
		           ball_x_next = (rand_0 * 10)+120;
	               ball_y_next = (rand_1 * 10)+40;
		       end
		   end
		   end
		   snake_eat_ball_next = 0;
	end
   
   always@(posedge snake_Hz)
	begin
	    head_hit_next = head_hit_body;
	    // Equalize next with reg
        for(count_reg = 0; count_reg < SNAKE_MAX_SIZE; count_reg = count_reg + 1)
		begin
		      snake_x_next[count_reg] = snake_x_reg[count_reg];
		      snake_y_next[count_reg] = snake_y_reg[count_reg];
		end
        // Handles body updating
		for(count_reg = 0; count_reg < SNAKE_MAX_SIZE; count_reg = count_reg + 1)
		begin
		if (count_reg == 0) begin
		     snake_x_next[count_reg] = snake_x_reg[count_reg] + x_delta_reg;
			 snake_y_next[count_reg] = snake_y_reg[count_reg] + y_delta_reg;
		end
		else if (count_reg < snake_body_no) begin
		     snake_x_next[count_reg] = snake_x_reg[count_reg-1];
			 snake_y_next[count_reg] = snake_y_reg[count_reg-1];
	    end
		end
		// Handles snake hitting itself
		for(count_reg = 3; count_reg < SNAKE_MAX_SIZE; count_reg = count_reg + 1)
		begin
		  if (count_reg < snake_body_no) begin
              if ((snake_x_next[0] == snake_x_reg[count_reg])&&(snake_y_next[0] == snake_y_reg[count_reg])) begin
                  head_hit_next = 1;
              end
		  end
		end
	end
   
   always @*
   begin
   events_next = events;
   // The pause/!start switch
   if (start) begin
        snake_stop = 1; // Reset for the snake Hz clk
        events_next[0] = 1;
   end
   else begin
        snake_stop = 0;
        events_next[0] = 0;
   end
   // play a beep when snake eats the ball
   events_next[1] = beep_sec;
   if ((snake_x_reg[0] == ball_x_reg)&&(snake_y_reg[0] == ball_y_reg)) begin
        beep_event = 1;
   end
   else begin
        if (~beep_sec) beep_event = 0; 
   end
   // rule shows for when reset for ten sec
   if (btn[4]) begin
        reset_event = 1;
        rule_event = 1;
   end
   else begin
    if (~rule_sec)
        rule_event = 0;
   end
   // high score assignment
   if (snake_body_no > high_score) begin
       high_score = snake_body_no;
   end
   // equalize the movement registers
   x_delta_next = x_delta_reg;
   y_delta_next = y_delta_reg;
      if (refr_tick)
        // tail direction detection
         if (snake_x_reg[snake_body_no-2] - snake_x_reg[snake_body_no-1] == -10) begin
	       tail_direction = 4'h0;
	    end
	    else if (snake_x_reg[snake_body_no-2] - snake_x_reg[snake_body_no-1] == 10) begin
	       tail_direction = 4'h1;
	    end
	    else if (snake_y_reg[snake_body_no-2] - snake_y_reg[snake_body_no-1] == 10) begin
	       tail_direction = 4'h3;
	    end
	    else if (snake_y_reg[snake_body_no-2] - snake_y_reg[snake_body_no-1] == -10) begin
	       tail_direction = 4'h2;
	    end
	    // button dectection with head direction
         if (btn[0]) begin // move up
         if (y_delta_next == 0) begin
            x_delta_next = 0;
			y_delta_next = SNAKE_V_N;
			direction = 4'h2;
            end
            end
         else if (btn[1]) begin // move left
         if (x_delta_next == 0) begin
            x_delta_next = SNAKE_V_N;
			y_delta_next = 0;
			direction = 4'h0;
            end
            end
         else if (btn[2]) begin // move right   
         if (x_delta_next == 0) begin
                x_delta_next = SNAKE_V_P;
                y_delta_next = 0;
                direction = 4'h1;
			end
            end
         else if (btn[3]) begin // move down
         if (y_delta_next == 0) begin
                x_delta_next = 0;
                y_delta_next = SNAKE_V_P;
                direction = 4'h3;
            end
            end
         // Game Condition checking
         if ((x_delta_reg != 0) || (y_delta_reg != 0)) begin
         // only check for game conditions if the game have started properly
         start_up = 0;
         if (reached_wall || head_hit_body) begin 
            events_next[2] = 1;
            snake_stop = 1;
         end   
         // Win Condition test
         if (infinite) begin
             if (snake_body_no >= SNAKE_MAX_SIZE) begin
                events_next[3] = 1;
                snake_stop = 1;
             end
         end
         else begin
            if (snake_body_no >= 24) begin
                events_next[3] = 1;
                snake_stop = 1;
             end
         end
         end
         
   end
   // Snake hits the wall
   assign reached_wall = (snake_x_l[0] <= WALLL_X_R-10) || (snake_x_r[0] >= WALLR_X_L) || 
                        (snake_y_t[0] <= WALLT_Y_B-10) || (snake_y_b[0] >= WALLB_Y_T);
    // Loop that handles where to draw the snake
	always@(posedge  MHz25)//MHz25)
	begin
	   // head square with head rom bit
	   snake_head_on = (snake_x_l[0]<=pix_x) && (pix_x<=snake_x_r[0]) && (snake_y_t[0]<=pix_y) && (pix_y<=snake_y_b[0]) && head_bit;
	   // tail square with tail rom bit
	   snake_tail_on = (snake_x_l[snake_body_no-1]<=pix_x) && (pix_x<=snake_x_r[snake_body_no-1]) && (snake_y_t[snake_body_no-1]<=pix_y) && (pix_y<=snake_y_b[snake_body_no-1]) && tail_bit;
		for(count_reg = 1; count_reg < SNAKE_MAX_SIZE; count_reg = count_reg + 1) begin
		    if (count_reg == 1) begin
		         square_snake_on = (snake_x_l[count_reg]<=pix_x) && (pix_x<=snake_x_r[count_reg]) && (snake_y_t[count_reg]<=pix_y) && (pix_y<=snake_y_b[count_reg]);
		    end
			else if(count_reg < snake_body_no-1) begin		
				 square_snake_on = square_snake_on || (snake_x_l[count_reg]<=pix_x) && (pix_x<=snake_x_r[count_reg]) && (snake_y_t[count_reg]<=pix_y) && (pix_y<=snake_y_b[count_reg]);
			end
		end
	end

   //--------------------------------------------
   // square ball
   //--------------------------------------------
   // boundary
   assign ball_x_l = ball_x_reg;
   assign ball_y_t = ball_y_reg;
   assign ball_x_r = ball_x_l + BALL_SIZE - 1;
   assign ball_y_b = ball_y_t + BALL_SIZE - 1;
   // pixel within ball
   assign sq_ball_on =
            (ball_x_l<=pix_x) && (pix_x<=ball_x_r) &&
            (ball_y_t<=pix_y) && (pix_y<=ball_y_b);
   // map current pixel location to ROM addr/col
   assign rom_addr = pix_y[3:0] - ball_y_t[3:0];
   assign rom_col = pix_x[3:0] - ball_x_l[3:0];
   assign rom_bit = rom_data[rom_col];
   // pixel within ball
   assign rd_ball_on = sq_ball_on & rom_bit;
   // ball rgb output
   assign ball_rgb = 12'b111100100010;   // light red

   // map pixel to snake head rom with direction
   assign head_addr = {direction,pix_y[3:0] - snake_y_t[0][3:0]};
   assign head_col = pix_x[3:0] - snake_x_l[0][3:0];
   assign head_bit = head_data[head_col];
   // map pixel to snake head rom with direction
   assign tail_addr = {tail_direction,pix_y[3:0] - snake_y_t[snake_body_no-1][3:0]};
   assign tail_col = pix_x[3:0] - snake_x_l[snake_body_no-1][3:0];
   assign tail_bit = tail_data[tail_col];
   // all of snake pixels
   assign snake_on = square_snake_on || snake_head_on || snake_tail_on;
   assign bg_rgb = 12'b111111010000; // dark yellow
   //--------------------------------------------
   // rgb multiplexing circuit
   //--------------------------------------------
   always @*
      if (~video_on)
         graph_rgb = 12'b000000000000; // blank
      else
         if (infinite && text_on2[3]) // show high score in infinite mode
            graph_rgb = text_rgb2;
         else if (text_on2[2]) // score
            graph_rgb = text_rgb2;
         else if (rule_sec && (text_on2[1] || text_on2[0])) // rules
            graph_rgb = text_rgb2;
         else if (wall_on)
            graph_rgb = wall_rgb;
         else if (snake_on)
            graph_rgb = snake_rgb;
         else if (rd_ball_on)
            graph_rgb = ball_rgb;
         else if (events[3] && text_on1[1]) // game win 
                graph_rgb = text_rgb1;
         else if ( text_on1[2] || // logo
               ((events[2]) && text_on1[0])) // game_over
            graph_rgb = text_rgb1;
         else if (grid_on)
            graph_rgb = grid_rgb;
         else if (play_area_on)
            graph_rgb = play_area_rgb;
         else
            graph_rgb = bg_rgb; // yellow background

endmodule
