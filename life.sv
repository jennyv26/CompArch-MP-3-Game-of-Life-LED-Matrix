module life(
    input logic [63:0] grid,
    output logic [63:0] next_grid
);
    integer r,c,dr,dc,nr,nc;
    logic [3:0] live_neighbors; // 4 neighbors
    
    always_comb begin
        next_grid = 64'b0;

        for (r = 0; r < 8; r = r+1) begin
            for (c = 0; c < 8; c = c+1) begin
                live_neighbors = 0;
                for (dr = -1; dr <= 1; dr = dr +1 ) begin// check for neighbors at -1, 1 but skip 0 since its the cell we're checking
                    for (dc = -1; dc <= 1; dc = dc + 1) begin
                        if (!(dr == 0 && dc == 0)) begin // skips checking the center because ! flips the condition, so look at when its not 0
                            nr = ((r + dr + 8) % 8); // add direction, left or right (-1,1) then add 8 to keep it positive, divide by 8 and get remainder so its wraps around
                            nc = ((c + dc + 8) % 8);
                            live_neighbors += grid[nr * 8 + nc]; // add neighbors in rows and columns
                        end
                    end
                end

                if (grid[r * 8 + c])  // checks if cell is alive 
                    next_grid[r * 8 + c] = (live_neighbors == 2 || live_neighbors == 3);
                else // cell is dead but comes alive 
                     next_grid[r * 8 + c] = (live_neighbors == 3);
                    
                
            end
        end
    end
    
endmodule