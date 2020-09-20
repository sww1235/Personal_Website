<h1 id="top">Contributing</h1>


How I setup suckless software such as st and dwm on void linux using
`void-packages` and `xbps-src`.

Note:

If you use the `build-branch-$hostname` branch of my fork of the
`void-packages` repo, then all these changes should already be in place.
Rebasing and debugging may be necessary if version bumps have happened.

<h2 id="prereqs">Prerequisites</h2>

Setup `void-packages` according to the instructions [here](void-packages-setup)


<h2 id="dwm">DWM install</h2>

First thing we want to do, is add patches.

Create a `patches` directory in `srcpkgs/dwm/` then add the following patches
to the correct machine specific build-branch.

<h3 id="status2d">status2d</h3>

wget correct patch for dwm from suckless website


<h3 id="status2d-the-machine">Host: The Machine</h3>

add the following to config.h


<h2 id="slstatus">slstatus</h2>

Configure `config.h` in `srcpkgs/slstatus/files`

The format argument in the struct in `config.h` uses `sprintf` format string
syntax. All variables are strings.

this can use flags from [status2d](#status2d) in its format strings if the
status2d patch is included in dwm.


```tags
Contributing, info
```
