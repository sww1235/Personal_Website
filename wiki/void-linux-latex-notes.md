# Preferred LaTeX Install on Void Linux

Only install the package `texlive-bin` from `void-packages`. This is the
meta-package for the texlive core binaries (this does not include the layout
packages such as `latex`, `luaxtex`, `pdflatex`, etc) and will install the new
version of texlive when it is released every year, plus any updates that come
along during the year. This package will also install a package named
`texliveYEAR-bin` which is a dependancy of the `texlive-bin` package. Older
versions of `texliveYEAR-bin` packages may still exist in the repository, and
on your computer after the update.

You can have multiple versions of `texliveYEAR-bin` installed at the same time,
but the texlive update infrastructure is only made available for the current
year's release.

The core and formatting binaries are installed at `/opt/texlive/YEAR/bin/arch/`
which either needs to be added to your path or directly navigated to. (There is
some potential auto add to `$Profile`, but I need to investigate that)

[Per](https://tex.stackexchange.com/a/383629)
[some](https://tex.stackexchange.com/a/107162)
[answers](https://tex.stackoverflow.com/a/493971) a better understanding of how
texlive is packaged and developed is found. In short, all packages available
within the texlive distribution (presumably not everything available via CTAN)
and the binaries are frozen in spring? and that batch of files are archived as
that year's distribution. During the freeze, the new version of the binaries
are built. Then after the freeze is thawed, the next yearly release is started
with a new package release from OS distro package maanagers. Between this point
and the next freeze, binaries are mostly static with only minor bug fixes or
minor features potentailly being released due to compilation and patching
efforts. Updates to macro and CTAN packages are absorbed through a semi-manual
process and are published via texlive.
