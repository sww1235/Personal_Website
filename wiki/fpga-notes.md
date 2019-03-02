<h1 id="top">FPGA Notes</h1>

<h2 name="lattice-fpgas">Lattice Ice40 FPGAs</h2>

Using internal libraries in VHDL need to look at actual contents of files in
install directory, located at
`./lscc/iCEcube2.2016.02/vhdl/sb_ice_syn_vital.vhd`. This contains the compiler
prototypes.

might need to add:

```vhdl
library sb_ice40_components_syn;
use sb_ice40_components_syn.components.all;
```

in order to get things to work.

Also might need to declare components manually.

Code from
<http://we.easyelectronics.ru/teplofizik/podklyuchenie-vstroennogo-modulya-tokovogo-drayvera-fpga-serii-ice5-ice40-ultra.html>


Verilog Library description:
```verilog
SB_RGB_DRV RGB_DRIVER (
.RGBLEDEN(ENABLE_LED),
.RGB0PWM(RGB0),
.RGB1PWM(RGB1),
.RGB2PWM(RGB2),
.RGBPU(led_power_up),
.RGB0(LED0),
.RGB1(LED1),
.RGB2(LED2)
);
defparam RGB_DRIVER.RGB0_CURRENT = "0b111111";
defparam RGB_DRIVER.RGB1_CURRENT = "0b111111";
defparam RGB_DRIVER.RGB2_CURRENT = "0b111111";
```

VHDL component:
```vhdl
component SB_RGB_DRV is
        generic (
                RGB0_CURRENT : string := "0b000000";
                RGB1_CURRENT : string := "0b000000";
                RGB2_CURRENT : string := "0b000000");
        port (RGBLEDEN, RGBPU, RGB0PWM, RGB1PWM, RGB2PWM: in std_logic;
                RGB0, RGB1, RGB2: out std_logic);
end component;
```

```tags
Contributing, info
```
