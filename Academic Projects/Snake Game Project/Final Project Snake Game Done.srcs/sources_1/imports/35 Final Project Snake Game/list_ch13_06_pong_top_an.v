// Listing 13.6
module snake_top_an
   (
    input wire clk, reset, reset_clk, start, difficulty, infinite,
    input wire [4:0] btn,
    output wire hsync, vsync,
    output wire [11:0] rgb,
    output reg audioOut,
    output wire aud_sd,
    output wire [4:0] events
   );

   // signal declaration
   wire [9:0] pixel_x, pixel_y;
   wire video_on, pixel_tick, clk_50m;
   reg playBGM, playBeep, playWin, playLose;
   reg [11:0] rgb_reg;
   wire [11:0] rgb_next;
   wire audioOut0, audioOut1, audioOut2, audioOut3;

   // Music and Sound
   assign aud_sd = 1'b1;
   SongPlayerBGM myBGM(clk, reset, playBGM, audioOut0);
   SongPlayerBeep myBeep(clk, reset, playBeep, audioOut1);
   LoseSongPlayer myLose(clk, reset, playLose, audioOut2);
   WinSongPlayer myWin(clk, reset, playWin, audioOut3);
   // body
   clk_50m_generator clk50MHz(clk, reset_clk, clk_50m);
   // instantiate vga sync circuit
   vga_sync vsync_unit
      (.clk(clk_50m), .reset(reset), .hsync(hsync), .vsync(vsync),
       .video_on(video_on), .p_tick(pixel_tick),
       .pixel_x(pixel_x), .pixel_y(pixel_y));

   // instantiate graphic generator
   snake_graph_animate snake_graph_an_unit
      (.clk(clk_50m), .reset(reset), .start(start), .difficulty(difficulty),
       .infinite(infinite), .btn(btn), .video_on(video_on), .pix_x(pixel_x),
       .pix_y(pixel_y), .graph_rgb(rgb_next), .events(events));
       
   assign playSound = 1;
   // rgb buffer
   always @(posedge clk_50m)
      if (pixel_tick)
         rgb_reg <= rgb_next;
   // output
   assign rgb = rgb_reg;
   always @ *
    begin
        if (events[0] == 1) begin
            playBeep <= 0;
            playBGM <= 0;
            playLose <= 0;
            playWin <= 0;
            audioOut <= audioOut;
        end
        else if (events[1] == 1) begin
            playBeep <= 1;
            playBGM <= 0;
            playLose <= 0;
            playWin <= 0;
            audioOut <= audioOut1;
        end
        else if (events[2] == 1) begin
            playBeep <= 0;
            playBGM <= 0;
            playLose <= 1;
            playWin <= 0;
            audioOut <= audioOut2;
        end
        else if (events[3] == 1) begin
            playBeep <= 0;
            playBGM <= 0;
            playLose <= 0;
            playWin <= 1;
            audioOut <= audioOut3;
        end
        else begin
            playBGM <= 1;
            playBeep <= 0;
            playLose <= 0;
            playWin <= 0;
            audioOut <= audioOut0;
        end
    end

endmodule
