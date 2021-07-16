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
equipment like its XLR audio adapter.

### TTL Protocol {#ttl-protocol}

At this point, all TTL (Through The Lens) protocols that manufacturers use to
communicate with the flash units and set power, do red-eye reduction,
pre-flash, etc are officially undocumented. Several people have invested a lot
of time and effort into reverse engineering these protocols, especially the
Canon eTTL protocol.

### External Flash Power {#ext-flash-power}

## References {#references}

- [Hot Shoe Stack Exchange Answer - image source](https://photo.stackexchange.com/a/100154/99926)

```tags
Camera, Photography, hacking, flash
```
