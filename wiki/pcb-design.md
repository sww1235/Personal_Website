# PCB Design

In general, try to keep surface mounted components on the top layer as it makes
pick and place opperations easier.

## Two Layer PCBs {#two-layer}

Top layer should be used to route signal and power traces while the bottom layer
should be used for a ground plane. This should be kept as unbroken as possible,
and used only for short jumper traces.

## Four Layer PCBs {#four-layer}

Top layer is used for signal routing, along with bottom layer for jumper traces
or longer signal routing. The inner two layers are for power and ground. One
layer should be kept as uninterrupted as possible for the ground plane and the
other inner layer should be used primarily for routing of power traces and only
sparingly used for signal routing.

```tags
PCB, design, electronics
```
