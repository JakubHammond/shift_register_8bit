module shift_register (
    input  logic clk,
    input  logic rst,
    input  logic en,
    input  logic serial_in,
    output logic data_out
);

logic [7:0] stages; // 8 registers

always_ff @(posedge clk) begin
    if (rst) begin // reset behavior
        stages   <= '0;
        data_out <= 1'b0;
    end else if (en) begin // enable behavior, shift
        stages   <= {stages[6:0], serial_in};
        data_out <= stages[7];
    end
end

endmodule
