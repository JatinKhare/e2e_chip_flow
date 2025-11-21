* SPICE Testbench for 32-bit Adder Critical Path
* Measures carry propagation delay

.TITLE Adder Critical Path Simulation

.INCLUDE ../models/tt.pm
.INCLUDE ../netlist/adder32_extracted.sp

* Power supply
VDD VDD 0 DC 1.0
VSS VSS 0 DC 0.0

* Input stimuli - worst case carry propagation
* a = 0xFFFFFFFF, b = 0x00000000, cin = 1
Va0 a0 0 PWL(0ns 0V 1ns 1.0V)
Va1 a1 0 PWL(0ns 0V 1ns 1.0V)
* ... (all a inputs to 1.0V)
Va31 a31 0 PWL(0ns 0V 1ns 1.0V)

Vb0 b0 0 DC 0.0
* ... (all b inputs to 0V)

Vcin cin 0 PWL(0ns 0V 1ns 1.0V)

* Transient simulation
.TRAN 0.01ns 15ns

* Measurements
.MEASURE TRAN tdelay TRIG V(cin) VAL=0.5V RISE=1 
+                     TARG V(cout) VAL=0.5V RISE=1

.MEASURE TRAN trise TRIG V(cout) VAL=0.1V RISE=1 
+                    TARG V(cout) VAL=0.9V RISE=1

.PRINT TRAN V(cin) V(c1) V(c16) V(c31) V(cout)

.END

