`include "memory.sv"
`include "ws2812b.sv"
`include "controller.sv"
`include "life.sv"

// led_matrix top level module

module top(
    input logic     clk,
    input logic     SW,
    input logic     BOOT,
    output logic    _48b
    );

    logic [7:0] red_data;
    logic [7:0] green_data;
    logic [7:0] blue_data;

    logic [5:0] pixel;
    logic [4:0] frame;  
    logic [10:0] address; 

    logic [4:0] previous_frame = 5'd0;
    logic [4:0] hue_idx = 5'd0; // changes color once per generation 
    logic [63:0] current_grid;
    logic [63:0] next_grid;

    logic [23:0] shift_reg = 24'd0;
    logic load_sreg;    
    logic transmit_pixel;
    logic shift;
    logic ws2812b_out;

    logic [7:0] init_rows [0:7];
    logic [63:0] init_grid;
    logic start = 1'b0;
    
    assign init_grid = { init_rows[7], init_rows[6], init_rows[5], init_rows[4],
                     init_rows[3], init_rows[2], init_rows[1], init_rows[0] };

    initial begin
        $readmemh ("glider.txt", init_rows);
    end
    assign address = { hue_idx, pixel };

    memory #(
        .INIT_FILE("life/red.txt")
    ) u1 (
        .clk            (clk), 
        .read_address   (address), 
        .read_data      (red_data)
    );

    // Instance sample memory for green channel
    memory #(
        .INIT_FILE      ("life/green.txt")
    ) u2 (
        .clk            (clk), 
        .read_address   (address), 
        .read_data      (green_data)
    );

    // Instance sample memory for blue channel
    memory #(
        .INIT_FILE      ("life/blue.txt")
    ) u3 (
        .clk            (clk), 
        .read_address   (address), 
        .read_data      (blue_data)
    );

    // Instance the WS2812B output driver
    ws2812b u4 (
        .clk            (clk), 
        .serial_in      (shift_reg[23]), 
        .transmit       (transmit_pixel), 
        .ws2812b_out    (ws2812b_out), 
        .shift          (shift)
    );

    // Instance the controller
    controller u5 (
        .clk            (clk), 
        .load_sreg      (load_sreg), 
        .transmit_pixel (transmit_pixel), 
        .pixel          (pixel), 
        .frame          (frame)
    );

    life u6 (
        .grid           (current_grid),
        .next_grid      (next_grid)
    );


    always_ff @(posedge clk) begin
        if (load_sreg) begin
           shift_reg <= {current_grid[pixel] ? green_data : 8'd0,
                           current_grid[pixel] ? red_data   : 8'd0,
                           current_grid[pixel] ? blue_data  : 8'd0}; // Load the shift register with the current pixel's GRB values because WS2812B expects data in GRB order
        end
        else if (shift) begin
            shift_reg <= { shift_reg[22:0], 1'b0 };
        end
    end

    always_ff @(posedge clk) begin
        previous_frame <= frame;
        start <= 1'b1;
        unique case ({start, BOOT}) 
            2'b00,
            2'b01,
            2'b10: begin 
                current_grid <= init_grid;
                hue_idx <= 5'd0;
            end
            2'b11: begin
                if (frame == 5'd0 && previous_frame != 5'd0)  begin
                current_grid <= next_grid;
                hue_idx <= hue_idx + 5'd1;
                end
            end
        endcase
         
    end

    assign _48b = ws2812b_out;


endmodule

    