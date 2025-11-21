# Post-route SDC (same as synthesis but for sign-off)
create_clock -period 10.0 [get_ports clk]
set_clock_uncertainty -setup 0.5 [get_clocks clk]
set_clock_uncertainty -hold 0.2 [get_clocks clk]
set_input_delay -max 2.0 -clock clk [all_inputs]
set_output_delay -max 2.0 -clock clk [all_outputs]

