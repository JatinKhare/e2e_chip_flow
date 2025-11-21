* SPICE Model File - Typical-Typical (TT) Corner
* Technology: 28nm CMOS
* Temperature: 25°C
* Voltage: 1.0V

.MODEL nmos_tt NMOS (
+ LEVEL=54 VERSION=4.7
+ TOX=1.2e-9 VTH0=0.42
+ U0=450 UA=-1.2e-9 UB=2.0e-18
+ LINT=5e-9 WINT=5e-9
+ K1=0.53 K2=0.032
+ VSAT=1.2e5
+ ... (additional BSIM4 parameters)
)

.MODEL pmos_tt PMOS (
+ LEVEL=54 VERSION=4.7
+ TOX=1.2e-9 VTH0=-0.40
+ U0=120 UA=-8.5e-10 UB=1.4e-18
+ LINT=5e-9 WINT=5e-9
+ K1=0.58 K2=0.025
+ VSAT=9.5e4
+ ... (additional BSIM4 parameters)
)

* Use these models for typical case simulation

