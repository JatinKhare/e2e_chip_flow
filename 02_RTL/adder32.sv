//==============================================================================
// Module: adder32
// Description: 32-bit ripple-carry adder with overflow detection
//              Implements registered inputs and outputs for better timing
// Author: RTL Design Team
// Date: 2024-01-15
//==============================================================================

module adder32 
  import adder_pkg::*;
(
  // Clock and Reset
  input  logic        clk,       // System clock
  input  logic        rst_n,     // Active-low asynchronous reset
  
  // Input Operands
  input  logic [31:0] a,         // First operand
  input  logic [31:0] b,         // Second operand
  input  logic        carry_in,  // Carry input (for chaining adders)
  
  // Output Results
  output logic [31:0] sum,       // Sum output
  output logic        carry_out, // Carry output
  output logic        overflow   // Signed overflow flag
);

  //============================================================================
  // Internal Signals
  //============================================================================
  
  // Registered inputs (pipeline stage 0)
  logic [31:0] a_reg;
  logic [31:0] b_reg;
  logic        carry_in_reg;
  
  // Combinational adder results
  logic [31:0] sum_comb;
  logic        carry_out_comb;
  logic        overflow_comb;
  
  // Carry chain for ripple-carry adder
  logic [32:0] carry;  // carry[0] = carry_in, carry[32] = carry_out
  
  //============================================================================
  // Input Register Stage
  // Purpose: Register inputs to improve timing and ease constraints
  //============================================================================
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      a_reg        <= 32'h0;
      b_reg        <= 32'h0;
      carry_in_reg <= 1'b0;
    end else begin
      a_reg        <= a;
      b_reg        <= b;
      carry_in_reg <= carry_in;
    end
  end
  
  //============================================================================
  // Ripple-Carry Adder Logic
  // Architecture: 32 full adders chained together
  // Critical Path: carry[0] -> carry[1] -> ... -> carry[32]
  //============================================================================
  
  // Initialize carry chain
  assign carry[0] = carry_in_reg;
  
  // Generate 32 full adders
  genvar i;
  generate
    for (i = 0; i < 32; i++) begin : gen_full_adder
      
      // Full Adder logic for bit i
      // sum[i] = a[i] XOR b[i] XOR carry[i]
      // carry[i+1] = (a[i] AND b[i]) OR (carry[i] AND (a[i] XOR b[i]))
      
      logic sum_temp;
      logic carry_temp;
      
      // Sum calculation
      assign sum_temp = a_reg[i] ^ b_reg[i] ^ carry[i];
      assign sum_comb[i] = sum_temp;
      
      // Carry calculation (majority function)
      assign carry_temp = (a_reg[i] & b_reg[i]) | 
                         (carry[i] & (a_reg[i] ^ b_reg[i]));
      assign carry[i+1] = carry_temp;
      
    end : gen_full_adder
  endgenerate
  
  // Final carry out
  assign carry_out_comb = carry[32];
  
  //============================================================================
  // Overflow Detection Logic
  // Overflow occurs when:
  //   - Adding two positive numbers yields negative result, OR
  //   - Adding two negative numbers yields positive result
  // Logic: overflow = (a[31] == b[31]) && (sum[31] != a[31])
  //============================================================================
  
  assign overflow_comb = (a_reg[31] & b_reg[31] & ~sum_comb[31]) |  // (+) + (+) = (-)
                         (~a_reg[31] & ~b_reg[31] & sum_comb[31]);   // (-) + (-) = (+)
  
  //============================================================================
  // Output Register Stage
  // Purpose: Register outputs for better timing and consistent latency
  //============================================================================
  
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sum       <= 32'h0;
      carry_out <= 1'b0;
      overflow  <= 1'b0;
    end else begin
      sum       <= sum_comb;
      carry_out <= carry_out_comb;
      overflow  <= overflow_comb;
    end
  end
  
  //============================================================================
  // ASSERTIONS (for simulation/formal verification)
  //============================================================================
  
  `ifdef SIMULATION
  
    // Property: Check that overflow only occurs with same-sign operands
    property p_overflow_same_sign;
      @(posedge clk) disable iff (!rst_n)
      overflow_comb |-> (a_reg[31] == b_reg[31]);
    endproperty
    
    assert_overflow: assert property (p_overflow_same_sign)
      else $error("Overflow detected with different sign operands!");
    
    // Property: Verify full adder sum logic
    property p_full_adder_sum(int bit_idx);
      @(posedge clk) disable iff (!rst_n)
      sum_comb[bit_idx] == (a_reg[bit_idx] ^ b_reg[bit_idx] ^ carry[bit_idx]);
    endproperty
    
    // Check a few bits (checking all 32 would be verbose)
    assert_fa_sum_bit0:  assert property (p_full_adder_sum(0));
    assert_fa_sum_bit15: assert property (p_full_adder_sum(15));
    assert_fa_sum_bit31: assert property (p_full_adder_sum(31));
    
    // Coverage: Track interesting corner cases
    covergroup cg_adder_corners @(posedge clk);
      cp_a_zero:     coverpoint (a_reg == 32'h0);
      cp_b_zero:     coverpoint (b_reg == 32'h0);
      cp_a_all_ones: coverpoint (a_reg == 32'hFFFFFFFF);
      cp_b_all_ones: coverpoint (b_reg == 32'hFFFFFFFF);
      cp_overflow:   coverpoint overflow_comb;
      cp_carry_out:  coverpoint carry_out_comb;
    endgroup
    
    cg_adder_corners cg_inst = new();
    
  `endif
  
  //============================================================================
  // SYNTHESIS ATTRIBUTES (optional hints for synthesis tools)
  //============================================================================
  
  // Mark carry chain as critical path for timing optimization
  // synthesis translate_off
  // Pragma: carry chain critical path
  // synthesis translate_on
  
endmodule : adder32

