//==============================================================================
// Module: top
// Description: Top-level wrapper for the 32-bit adder design
//              Includes clock/reset management and I/O buffering
// Author: RTL Design Team
// Date: 2024-01-15
//==============================================================================

module top
  import adder_pkg::*;
(
  // Clock and Reset (from chip pads)
  input  logic        clk_pad,       // External clock input
  input  logic        rst_n_pad,     // External reset (active-low)
  
  // Primary Inputs (from chip pads)
  input  logic [31:0] a_pad,         // First operand
  input  logic [31:0] b_pad,         // Second operand
  input  logic        carry_in_pad,  // Carry input
  
  // Primary Outputs (to chip pads)
  output logic [31:0] sum_pad,       // Sum result
  output logic        carry_out_pad, // Carry output
  output logic        overflow_pad,  // Overflow flag
  
  // Optional: Test/Debug Signals
  input  logic        test_mode,     // Test mode enable
  input  logic        scan_enable,   // Scan chain enable (DFT)
  input  logic        scan_in,       // Scan chain input
  output logic        scan_out       // Scan chain output
);

  //============================================================================
  // Internal Signals
  //============================================================================
  
  // Buffered clock and reset
  logic clk_int;
  logic rst_n_int;
  
  // Buffered inputs
  logic [31:0] a_int;
  logic [31:0] b_int;
  logic        carry_in_int;
  
  // Internal results (before output buffering)
  logic [31:0] sum_int;
  logic        carry_out_int;
  logic        overflow_int;
  
  //============================================================================
  // Clock and Reset Buffering
  // Purpose: Reduce loading on pad drivers, provide clean signals
  //============================================================================
  
  // In real design, these would be special clock buffers (e.g., BUFG, ICG)
  assign clk_int = clk_pad;
  assign rst_n_int = rst_n_pad;
  
  // Optional: Add clock gating for power savings
  // logic clk_gated;
  // clock_gate u_clk_gate (
  //   .clk_in(clk_int),
  //   .enable(~test_mode),  // Disable gating in test mode
  //   .clk_out(clk_gated)
  // );
  
  //============================================================================
  // Input Buffering
  // Purpose: Isolate internal logic from pad loading
  //============================================================================
  
  always_ff @(posedge clk_int or negedge rst_n_int) begin
    if (!rst_n_int) begin
      a_int        <= 32'h0;
      b_int        <= 32'h0;
      carry_in_int <= 1'b0;
    end else begin
      a_int        <= a_pad;
      b_int        <= b_pad;
      carry_in_int <= carry_in_pad;
    end
  end
  
  //============================================================================
  // Main Adder Instantiation
  //============================================================================
  
  adder32 u_adder32 (
    .clk       (clk_int),
    .rst_n     (rst_n_int),
    .a         (a_int),
    .b         (b_int),
    .carry_in  (carry_in_int),
    .sum       (sum_int),
    .carry_out (carry_out_int),
    .overflow  (overflow_int)
  );
  
  //============================================================================
  // Output Buffering
  // Purpose: Drive output pads with buffered signals
  //============================================================================
  
  always_ff @(posedge clk_int or negedge rst_n_int) begin
    if (!rst_n_int) begin
      sum_pad       <= 32'h0;
      carry_out_pad <= 1'b0;
      overflow_pad  <= 1'b0;
    end else begin
      sum_pad       <= sum_int;
      carry_out_pad <= carry_out_int;
      overflow_pad  <= overflow_int;
    end
  end
  
  //============================================================================
  // Design-For-Test (DFT) Logic
  // Purpose: Support scan chain for manufacturing test
  //============================================================================
  
  // Simple scan chain stub (real design would connect all flip-flops)
  // In production, synthesis tools automatically insert scan chains
  
  logic scan_chain_internal;
  
  always_ff @(posedge clk_int or negedge rst_n_int) begin
    if (!rst_n_int) begin
      scan_chain_internal <= 1'b0;
    end else begin
      if (scan_enable) begin
        scan_chain_internal <= scan_in;  // Shift mode
      end else begin
        scan_chain_internal <= sum_int[0];  // Functional mode
      end
    end
  end
  
  assign scan_out = scan_chain_internal;
  
  //============================================================================
  // Functional Validation Checkers (Simulation Only)
  //============================================================================
  
  `ifdef SIMULATION
  
    // Check for X/Z propagation (should not occur in normal operation)
    always @(posedge clk_int) begin
      if (rst_n_int) begin
        if (^a_int === 1'bx) $error("X detected on a_int");
        if (^b_int === 1'bx) $error("X detected on b_int");
        if (^sum_int === 1'bx) $error("X detected on sum_int");
      end
    end
    
    // Monitor for valid operation
    initial begin
      $display("=================================================");
      $display(" 32-bit Adder Top Module");
      $display(" Design: Ripple-Carry with I/O Registers");
      $display(" Latency: 3 cycles (input reg + adder + output reg)");
      $display("=================================================");
    end
    
  `endif
  
  //============================================================================
  // Power Management Hooks (for low-power designs)
  //============================================================================
  
  // Placeholder for power domain isolation, retention, etc.
  // In real low-power design, would include:
  // - Power gating control
  // - Isolation cells
  // - Retention registers
  // - Voltage level shifters
  
  //============================================================================
  // Performance Counters (Optional Debug Feature)
  //============================================================================
  
  `ifdef DEBUG
  
    // Count number of operations performed
    logic [31:0] operation_count;
    
    always_ff @(posedge clk_int or negedge rst_n_int) begin
      if (!rst_n_int) begin
        operation_count <= 32'h0;
      end else begin
        operation_count <= operation_count + 1'b1;
      end
    end
    
  `endif
  
endmodule : top

