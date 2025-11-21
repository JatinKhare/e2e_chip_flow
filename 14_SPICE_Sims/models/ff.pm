* SPICE Model File - Fast-Fast (FF) Corner
* Technology: 28nm CMOS
* Temperature: -40°C
* Voltage: 1.1V

.MODEL nmos_ff NMOS (
+ LEVEL=54 VERSION=4.7
+ TOX=1.1e-9 VTH0=0.38
+ U0=520 VSAT=1.4e5
+ ... (fast corner parameters)
)

.MODEL pmos_ff PMOS (
+ LEVEL=54 VERSION=4.7
+ TOX=1.1e-9 VTH0=-0.36
+ U0=145 VSAT=1.1e5
+ ... (fast corner parameters)
)

