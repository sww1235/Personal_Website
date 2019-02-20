# FPGA Notes

## Lattice Ice40 FPGAs

Using internal libraries in VHDL need to look at actual contents of files in
install directory.

might need to add:

```vhdl
library sb_ice40_components_syn;
use sb_ice40_components_syn.components.all;
```

in order to get things to work.

Also might need to declare components manually.
