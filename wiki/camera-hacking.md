# Camera Hacking

See the [Camera Information and Terminology](camera-info.md) page for more
general discussion and terminology around digital photography and flashes.

Most of this info will be related to the cameras that I own and use, currently
a Panasonic GH5, but other info may be included as well if I find it.

A lot of this information will be duplicating information found other places on
the 'net. It will be cited as best as possible. I want the information in a
location that I control, to avoid the infomration getting lost when other
websites and forums get shut down or go extinct.

I am also trying to summarize and coorelate some of this info, as I have found
different pieces of it on different sites, and it was a real pain digging
through the Google search results for it all.

## Flashes {#flashes}

### Hot Shoe Research {#hot-shoe}

Most hot and cold shoes have a standard set of dimensions specified in ISO
518:2006. In addition to the physical dimensions, the location of the center
contact is also standardized.

![Hotshoe Comparison](hot_shoe_comparision.jpg)

The center contact and the metal 'U' shape of the hot act as a N.O. dry contact
that is closed when the camera tells the flash to fire. On older flashes, (and
some modern ones), the voltage that directly fires the flash is passed through
this contact which can be in excess of 300V. Some modern cameras use circuitry
that cannot handle the high voltages of older flashes, and need adapters in
order to not break.

Other connectors are commonly present in the hotshoe, which provide
communication to smart flashes and other accessories.

Most modern Canon cameras have 4 contacts to the rear of the center contact
which are wired as follows: TODO: Insert picture.

Modern Panasonic cameras either use 3 or 4 contacts in an identical spacing to
the Canon hotshoe layout, but with a different pinout. This means that flashes
and accessories will fit physically but not electrically, so Canon flash
extension cables will work on the new Panasonic 4 contact hotshoes.

Panasonic uses one (which one) of the 4 contacts to provide accessory power to
equipment like their XLR audio adapter.

### TTL Protocol {#ttl-protocol}

At this point, all TTL (Through The Lens) protocols that manufacturers use to
communicate with the flash units and set power, do red-eye reduction,
pre-flash, etc are officially undocumented. Several people have invested a lot
of time and effort into reverse engineering these protocols, especially the
Canon eTTL protocol.

### External Flash Power {#ext-flash-power}

Most Speedlites (external on-camera flashes) use AA batteries for power. This
provides power to the electronics and the flash mechanism. The flash mechanism
itself needs anywhere between 200VDC-500VDC to actually power the xenon tube.
This high voltage is typically upconverted from the ~12VDC of the AA batteries
and stored in a capacitor. This capacitor takes time (between 1 to 5 seconds)
to recharge between shots, thus limiting the rate at which you can take photos.

The AA batteries work well, but regularly require replacement and cause slow
recharge times, especially as they are depleted. Using NIMH rechargable AAs can
help reduce these issues, but not eliminate them. Some newer flashes are using
Li-Ion batteries similar (but not identical) to the batteries used by camera
bodies, but they are also propriatary and not compatible with the camera
batteries.

Some flashes have an external power connection to help reduce the usage of
batteries. In some cases, this is a LVDC input that replaces the batteries
completely. In other cases, the power connection is a HVDC input that directly
interfaces with the capacitor charging circuitry. These HVDC connections allow
for much faster capacitor recharging.

## The Goal (#the-goal}

My ultimate goal is to be able to standardize on one style of battery pack
(like Anton Bauer Vmount/Gold mount) to power all my equipment, including
camera body and flash.

## References {#references}

- [Hot Shoe Stack Exchange Answer - image source](https://photo.stackexchange.com/a/100154/99926)

```tags
Camera, Photography, hacking, flash
```
