module pattern_memory (
    input wire clk,
    input wire write_en,
    input wire [5:0] addr,
    input wire [1:0] data_in,
    output wire [1:0] data_out
);

    reg [1:0] memory_array [0:63];
    
    assign data_out = memory_array[addr];
    
    always @(posedge clk) begin
        if (write_en) begin
            memory_array[addr] <= data_in;
        end
    end
    
endmodule