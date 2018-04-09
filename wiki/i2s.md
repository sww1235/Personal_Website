<h1 id="top">I<sup>2</sup>C</h1>

I2S consists of serial data, the bit clock and the word clock. In addition there
may be a master clock which is used by ADCs and DACs to sync their master
clocks.

I2S by spec represents data in 2s complement format. In any bit width
conversion, truncation or zero fill is applied. Quoting from the I2S spec:

>When the system word length is greater than the transmitter word
>length, the word is truncated (least significant data bits are set to ‘0’)
>for data transmission. If the receiver is sent more bits than its word
>length, the bits after the LSB are ignored. On the other hand, if the
>receiver is sent fewer bits than its word length, the missing bits are
>set to zero internally. And so, the MSB has a fixed position, whereas
>the position of the LSB depends on the word length. The transmitter
>always sends the MSB of the next word one clock period after the
>WS changes.

<h2 id="references">References</h2>

-   <https://web.archive.org/web/20070102004400/http://www.nxp.com/acrobat_download/various/I2SBUS.pdf>

```tags

electronics, protocols, i2s, communication

```
