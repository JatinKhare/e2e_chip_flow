//==============================================================================
// Module: tb_adder32
// Description: Comprehensive testbench for 32-bit adder verification
//              Includes directed tests, random tests, and self-checking
// Author: Verification Team
// Date: 2024-01-15
//==============================================================================

`timescale 1ns/1ps

module tb_adder32;

  import adder_pkg::*;

  //============================================================================
  // Clock and Reset Generation
  //============================================================================
  
  logic clk;
  logic rst_n;
  
  // Clock generation: 100 MHz (10ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // Toggle every 5ns
  end
  
  // Reset generation
  initial begin
    rst_n = 0;
    #25 rst_n = 1;  // Release reset after 25ns
  end
  
  //============================================================================
  // DUT (Device Under Test) Signals
  //============================================================================
  
  logic [31:0] a;
  logic [31:0] b;
  logic        carry_in;
  logic [31:0] sum;
  logic        carry_out;
  logic        overflow;
  
  //============================================================================
  // DUT Instantiation
  //============================================================================
  
  adder32 dut (
    .clk       (clk),
    .rst_n     (rst_n),
    .a         (a),
    .b         (b),
    .carry_in  (carry_in),
    .sum       (sum),
    .carry_out (carry_out),
    .overflow  (overflow)
  );
  
  //============================================================================
  // Test Control Variables
  //============================================================================
  
  int test_count;
  int pass_count;
  int fail_count;
  
  //============================================================================
  // Reference Model (Golden Reference)
  //============================================================================
  
  function automatic void check_result(
    input logic [31:0] a_in,
    input logic [31:0] b_in,
    input logic        cin,
    input logic [31:0] sum_actual,
    input logic        cout_actual,
    input logic        ovf_actual
  );
    logic [32:0] expected_result;
    logic        expected_cout;
    logic        expected_ovf;
    logic [31:0] expected_sum;
    
    // Calculate expected result (33-bit to capture carry)
    expected_result = {1'b0, a_in} + {1'b0, b_in} + {32'b0, cin};
    expected_sum = expected_result[31:0];
    expected_cout = expected_result[32];
    
    // Calculate expected overflow
    expected_ovf = (a_in[31] == b_in[31]) && (expected_sum[31] != a_in[31]);
    
    // Check results
    if (sum_actual !== expected_sum || 
        cout_actual !== expected_cout || 
        ovf_actual !== expected_ovf) begin
      $display("[FAIL] Test #%0d at time %0t", test_count, $time);
      $display("  Inputs:  a=0x%08h, b=0x%08h, cin=%b", a_in, b_in, cin);
      $display("  Expected: sum=0x%08h, cout=%b, ovf=%b", 
               expected_sum, expected_cout, expected_ovf);
      $display("  Actual:   sum=0x%08h, cout=%b, ovf=%b", 
               sum_actual, cout_actual, ovf_actual);
      fail_count++;
    end else begin
      $display("[PASS] Test #%0d: 0x%08h + 0x%08h + %b = 0x%08h (cout=%b, ovf=%b)",
               test_count, a_in, b_in, cin, sum_actual, cout_actual, ovf_actual);
      pass_count++;
    end
    
    test_count++;
  endfunction
  
  //============================================================================
  // Test Stimulus Task
  //============================================================================
  
  task apply_test(
    input logic [31:0] a_val,
    input logic [31:0] b_val,
    input logic        cin_val
  );
    // Apply inputs
    @(posedge clk);
    a = a_val;
    b = b_val;
    carry_in = cin_val;
    
    // Wait for result (3 cycle latency: input reg + compute + output reg)
    repeat(3) @(posedge clk);
    
    // Check result
    check_result(a_val, b_val, cin_val, sum, carry_out, overflow);
  endtask
  
  //============================================================================
  // Directed Tests
  //============================================================================
  
  initial begin
    test_count = 0;
    pass_count = 0;
    fail_count = 0;
    
    $display("==========================================================");
    $display(" 32-bit Adder Testbench");
    $display(" Starting Verification...");
    $display("==========================================================");
    
    // Wait for reset
    wait(rst_n);
    @(posedge clk);
    
    $display("\n--- Directed Tests ---");
    
    // Test 1: Zero + Zero
    $display("\nTest Category: Basic Operations");
    apply_test(32'h00000000, 32'h00000000, 1'b0);
    
    // Test 2: Zero + One
    apply_test(32'h00000000, 32'h00000001, 1'b0);
    
    // Test 3: One + One
    apply_test(32'h00000001, 32'h00000001, 1'b0);
    
    // Test 4: Max value + 0
    apply_test(32'hFFFFFFFF, 32'h00000000, 1'b0);
    
    // Test 5: Max value + 1 (should wrap around with carry)
    $display("\nTest Category: Overflow/Carry");
    apply_test(32'hFFFFFFFF, 32'h00000001, 1'b0);
    
    // Test 6: Max value + Max value
    apply_test(32'hFFFFFFFF, 32'hFFFFFFFF, 1'b0);
    
    // Test 7: Test carry_in
    $display("\nTest Category: Carry-in Tests");
    apply_test(32'h00000000, 32'h00000000, 1'b1);
    apply_test(32'hFFFFFFFF, 32'h00000000, 1'b1);
    
    // Test 8: Signed overflow positive + positive = negative
    $display("\nTest Category: Signed Overflow");
    apply_test(32'h7FFFFFFF, 32'h00000001, 1'b0);  // Max positive + 1
    apply_test(32'h40000000, 32'h40000000, 1'b0);  // Large pos + Large pos
    
    // Test 9: Signed overflow negative + negative = positive
    apply_test(32'h80000000, 32'h80000000, 1'b0);  // Min negative + Min negative
    apply_test(32'h80000000, 32'hFFFFFFFF, 1'b0);  // -2^31 + (-1)
    
    // Test 10: No overflow for mixed signs
    $display("\nTest Category: No Overflow (Mixed Signs)");
    apply_test(32'h7FFFFFFF, 32'h80000000, 1'b0);  // Max pos + Min neg
    apply_test(32'h7FFFFFFF, 32'hFFFFFFFF, 1'b0);  // Max pos + (-1)
    
    // Test 11: Alternating bit patterns
    $display("\nTest Category: Bit Patterns");
    apply_test(32'hAAAAAAAA, 32'h55555555, 1'b0);  // Alt pattern
    apply_test(32'hAAAAAAAA, 32'hAAAAAAAA, 1'b0);
    apply_test(32'h55555555, 32'h55555555, 1'b0);
    
    // Test 12: Powers of 2
    $display("\nTest Category: Powers of 2");
    apply_test(32'h00000001, 32'h00000001, 1'b0);  // 2^0 + 2^0
    apply_test(32'h00000002, 32'h00000002, 1'b0);  // 2^1 + 2^1
    apply_test(32'h80000000, 32'h80000000, 1'b0);  // 2^31 + 2^31
    
    //==========================================================================
    // Random Tests
    //==========================================================================
    
    $display("\n--- Random Tests (100 iterations) ---");
    
    repeat(100) begin
      logic [31:0] rand_a, rand_b;
      logic rand_cin;
      
      rand_a = $random();
      rand_b = $random();
      rand_cin = $random() & 1'b1;
      
      apply_test(rand_a, rand_b, rand_cin);
    end
    
    //==========================================================================
    // Test Summary
    //==========================================================================
    
    $display("\n==========================================================");
    $display(" Test Summary");
    $display("==========================================================");
    $display(" Total Tests: %0d", test_count);
    $display(" Passed:      %0d", pass_count);
    $display(" Failed:      %0d", fail_count);
    
    if (fail_count == 0) begin
      $display("\n *** ALL TESTS PASSED *** ");
    end else begin
      $display("\n !!! SOME TESTS FAILED !!!");
    end
    
    $display("==========================================================\n");
    
    // Finish simulation
    #100;
    $finish;
  end
  
  //============================================================================
  // Waveform Dump
  //============================================================================
  
  initial begin
    $dumpfile("waves/adder.vcd");
    $dumpvars(0, tb_adder32);
  end
  
  //============================================================================
  // Timeout Watchdog
  //============================================================================
  
  initial begin
    #1000000;  // 1ms timeout
    $display("ERROR: Simulation timeout!");
    $finish;
  end
  
  //============================================================================
  // Assertions (for property checking)
  //============================================================================
  
  // Check that outputs don't have X or Z
  property p_no_x_on_sum;
    @(posedge clk) disable iff (!rst_n)
    !$isunknown(sum);
  endproperty
  
  assert_no_x_sum: assert property(p_no_x_on_sum)
    else $error("X/Z detected on sum output!");
  
  // Check overflow only with same-sign inputs
  property p_overflow_same_sign;
    @(posedge clk) disable iff (!rst_n)
    overflow |-> (a[31] == b[31]);
  endproperty
  
  assert_overflow_sign: assert property(p_overflow_same_sign)
    else $error("Overflow with different sign inputs!");
  
  //============================================================================
  // Coverage Collection
  //============================================================================
  
  covergroup cg_adder @(posedge clk);
    option.per_instance = 1;
    
    cp_a_zero:     coverpoint (a == 32'h0);
    cp_b_zero:     coverpoint (b == 32'h0);
    cp_a_all_ones: coverpoint (a == 32'hFFFFFFFF);
    cp_b_all_ones: coverpoint (b == 32'hFFFFFFFF);
    cp_carry_in:   coverpoint carry_in;
    cp_carry_out:  coverpoint carry_out;
    cp_overflow:   coverpoint overflow;
    
    // Cross coverage
    cross cp_carry_in, cp_carry_out;
    cross cp_overflow, cp_carry_out;
  endgroup
  
  cg_adder cg_inst = new();

endmodule : tb_adder32

