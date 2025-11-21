//==============================================================================
// Package: adder_pkg
// Description: SystemVerilog package containing parameters, types, and
//              constants for the 32-bit adder design
// Author: RTL Design Team
// Date: 2024-01-15
//==============================================================================

package adder_pkg;

  //============================================================================
  // PARAMETERS
  //============================================================================
  
  // Adder bit width - can be overridden for different sizes
  parameter int ADDER_WIDTH = 32;
  
  // Pipeline stages (for future enhancement)
  parameter int PIPELINE_STAGES = 0;  // 0 = no pipeline, 1+ = pipelined
  
  // Timing parameters (in ns, for documentation)
  parameter real CLOCK_PERIOD = 10.0;     // 100 MHz
  parameter real SETUP_TIME = 0.5;
  parameter real HOLD_TIME = 0.2;
  
  //============================================================================
  // TYPE DEFINITIONS
  //============================================================================
  
  // Adder operation types (for future multi-function ALU)
  typedef enum logic [1:0] {
    OP_ADD  = 2'b00,   // Addition
    OP_SUB  = 2'b01,   // Subtraction (future)
    OP_INC  = 2'b10,   // Increment (future)
    OP_DEC  = 2'b11    // Decrement (future)
  } alu_op_e;
  
  // Status flags structure
  typedef struct packed {
    logic overflow;      // Signed overflow
    logic carry_out;     // Unsigned carry out
    logic zero;          // Result is zero (future)
    logic negative;      // Result is negative (future)
  } status_flags_t;
  
  //============================================================================
  // CONSTANTS
  //============================================================================
  
  // Special values for testing
  localparam logic [ADDER_WIDTH-1:0] ALL_ZEROS = {ADDER_WIDTH{1'b0}};
  localparam logic [ADDER_WIDTH-1:0] ALL_ONES  = {ADDER_WIDTH{1'b1}};
  localparam logic [ADDER_WIDTH-1:0] PATTERN_AA = {ADDER_WIDTH{2'b10}};  // 0xAAAAAAAA
  localparam logic [ADDER_WIDTH-1:0] PATTERN_55 = {ADDER_WIDTH{2'b01}};  // 0x55555555
  
  // Maximum values
  localparam logic [ADDER_WIDTH-1:0] MAX_UNSIGNED = ALL_ONES;
  localparam logic [ADDER_WIDTH-1:0] MAX_SIGNED   = {1'b0, {(ADDER_WIDTH-1){1'b1}}};  // 0x7FFFFFFF
  localparam logic [ADDER_WIDTH-1:0] MIN_SIGNED   = {1'b1, {(ADDER_WIDTH-1){1'b0}}};  // 0x80000000
  
  //============================================================================
  // FUNCTIONS
  //============================================================================
  
  // Function: full_adder
  // Description: Behavioral full adder for 1 bit
  // Inputs: a, b, carry_in
  // Returns: {carry_out, sum}
  function automatic logic [1:0] full_adder(
    input logic a,
    input logic b, 
    input logic cin
  );
    logic sum, cout;
    sum = a ^ b ^ cin;
    cout = (a & b) | (cin & (a ^ b));
    return {cout, sum};
  endfunction
  
  // Function: detect_overflow
  // Description: Detects signed overflow in addition
  // Overflow when: (+) + (+) = (-) or (-) + (-) = (+)
  function automatic logic detect_overflow(
    input logic [ADDER_WIDTH-1:0] a,
    input logic [ADDER_WIDTH-1:0] b,
    input logic [ADDER_WIDTH-1:0] sum
  );
    logic a_sign, b_sign, sum_sign;
    a_sign = a[ADDER_WIDTH-1];
    b_sign = b[ADDER_WIDTH-1];
    sum_sign = sum[ADDER_WIDTH-1];
    
    // Overflow if both operands same sign but result is different sign
    return (a_sign == b_sign) && (sum_sign != a_sign);
  endfunction
  
  // Function: parity
  // Description: Calculate even parity for error detection
  function automatic logic parity(
    input logic [ADDER_WIDTH-1:0] data
  );
    return ^data;  // XOR reduction
  endfunction
  
  // Function: count_ones
  // Description: Count number of 1's in data (population count)
  function automatic int count_ones(
    input logic [ADDER_WIDTH-1:0] data
  );
    int count;
    count = 0;
    for (int i = 0; i < ADDER_WIDTH; i++) begin
      if (data[i]) count++;
    end
    return count;
  endfunction

  //============================================================================
  // ASSERTIONS / CHECKS (for simulation)
  //============================================================================
  
  // Check that width is reasonable
  initial begin
    assert (ADDER_WIDTH > 0 && ADDER_WIDTH <= 128) else
      $fatal(1, "ADDER_WIDTH must be between 1 and 128");
  end

endpackage : adder_pkg

