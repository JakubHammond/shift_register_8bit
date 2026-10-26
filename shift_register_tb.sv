`timescale 1ns/1ps

module shift_register_tb;
    logic clk = 0;
    logic rst = 1;
    logic en = 0;
    logic serial_in = 0;
    wire data_out;
    logic [7:0] pattern = 8'b10100110;

    shift_register dut (
        .clk(clk), .rst(rst), .en(en),
        .serial_in(serial_in), .data_out(data_out)
    );

    always #5 clk = ~clk;

    task automatic check_output(input logic expected);
        if (data_out !== expected)
            $fatal(1, "At %0t: expected output %b, got %b",
                   $time, expected, data_out);
    endtask

    // Change inputs on the falling edge, check after the rising edge.
    task automatic step(
        input logic enable_value,
        input logic input_bit,
        input logic expected
    );
        @(negedge clk);
        en = enable_value;
        serial_in = input_bit;
        @(posedge clk); #1;
        check_output(expected);
    endtask

    initial begin
        $dumpfile("shift_register.vcd");
        $dumpvars(0, shift_register_tb);

        // Reset establishes a known starting state.
        @(posedge clk); #1;
        check_output(0);
        @(negedge clk); rst = 0; en = 0;

        // A single 1 arrives on the ninth enabled edge, not the eighth.
        step(1, 1, 0);
        repeat (7) step(1, 0, 0);
        // Pausing must also preserve the eight INTERNAL stages.
        repeat (3) step(0, 1, 0);
        step(1, 0, 1);

        // Hold a high output while disabled, then shift it out.
        step(0, 0, 1);
        step(0, 1, 1);
        step(0, 0, 1);
        step(1, 0, 0);

        // Send a byte MSB first and check that bit order is preserved.
        for (int i = 7; i >= 0; i--)
            step(1, pattern[i], 0);
        for (int i = 7; i >= 0; i--)
            step(1, 0, pattern[i]);
        step(1, 0, 0);

        // Fill all stages, then reset while enable is also asserted.
        repeat (8) step(1, 1, 0);
        step(1, 1, 1);
        @(negedge clk); rst = 1;
        #1;
        check_output(1); // Synchronous reset waits for the rising edge.
        @(posedge clk); #1;
        check_output(0);
        @(negedge clk); rst = 0; en = 0;
        repeat (9) step(1, 0, 0); // Reset cleared the internal stages too.

        // New input still works after reset.
        step(1, 1, 0);
        repeat (7) step(1, 0, 0);
        step(1, 0, 1);

        $display("PASS: reset, nine-stage timing, bit order, enable hold, and recovery");
        $finish;
    end

    initial begin
        #10000;
        $fatal(1, "Simulation timed out");
    end
endmodule
