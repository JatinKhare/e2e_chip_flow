* Extracted Transistor-Level Netlist - Critical Path
* From carry_in to carry_out (32-bit carry chain)

.SUBCKT full_adder_0 a b cin sum cout VDD VSS
* Transistor-level implementation of full adder bit 0
* XOR gates for sum
M1 n1 a VDD VDD pmos_tt W=0.5u L=0.028u
M2 n1 a VSS VSS nmos_tt W=0.25u L=0.028u
M3 n2 b n1 VDD pmos_tt W=0.5u L=0.028u
M4 n2 b n1 VSS nmos_tt W=0.25u L=0.028u
M5 sum cin n2 VDD pmos_tt W=0.5u L=0.028u
M6 sum cin n2 VSS nmos_tt W=0.25u L=0.028u

* Majority function for carry
M7 cout a VDD VDD pmos_tt W=0.5u L=0.028u
M8 n3 b cout VSS nmos_tt W=0.25u L=0.028u
M9 n3 cin cout VSS nmos_tt W=0.25u L=0.028u
* ... (complete transistor netlist)
.ENDS

* Instantiate 32 full adders in chain
X0 a0 b0 cin sum0 c1 VDD VSS full_adder_0
X1 a1 b1 c1 sum1 c2 VDD VSS full_adder_0
* ... (X2 through X31)
X31 a31 b31 c31 sum31 cout VDD VSS full_adder_0

* Wire parasitics from extraction
Cwire_c1 c1 VSS 0.25fF
Rwire_c1 c1 c1_int 2.4
* ... (parasitics for all nets)

