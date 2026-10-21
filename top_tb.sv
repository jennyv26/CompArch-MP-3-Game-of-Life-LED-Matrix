`timescale 1ns/1ps
`include "top.sv"

module top_tb;

logic clk = 0;
logic SW = 1'b1;
logic BOOT = 1'b1;
logic _48b;


top u0 (
    .clk(clk), 
    .SW(SW), 
    .BOOT(BOOT), 
    ._48b(_48b)
);



initial begin
    integer fd;
    $dumpfile("top_tb.vcd");
    $dumpvars(0, top_tb);
    
    #100;
    fd = $fopen("memory_dump.txt", "w");
   
    // $display("current_grid = %b", u0.current_grid);

    $fdisplay(fd, "%b", u0.current_grid, u0.next_grid);
    $fclose(fd);
    #200000000; // 1 generation

    
    $finish;
end

always begin 
    #4 
    clk = ~clk; 
end



endmodule