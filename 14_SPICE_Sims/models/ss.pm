* SPICE Model File - Slow-Slow (SS) Corner
* Technology: 28nm CMOS
* Temperature: 125°C
* Voltage: 0.9V

.MODEL nmos_ss NMOS (
+ LEVEL=54 VERSION=4.7
+ TOX=1.3e-9 VTH0=0.46
+ U0=380 VSAT=1.0e5
+ ... (slow corner parameters)
)

.MODEL pmos_ss PMOS (
+ LEVEL=54 VERSION=4.7
+ TOX=1.3e-9 VTH0=-0.44
+ U0=100 VSAT=8.0e4
+ ... (slow corner parameters)
)

