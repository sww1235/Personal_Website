<h1 id="top">Void Packages Setup</h1>

Notes on setting up void packages and building from source. 


1.	Fork the [Void Packages](https://github.com/void-linux/void-packages)
	repo on github if you haven't already.

2.	Clone your fork locally (mine is at
	<https://github.com/sww1235/void-packages> and usually exists locally at
	~/Projects/src/github.com/sww1235/void-packages).

3.	`cd` into your local git repo and add the upstream repo `git remote add
	upstream git@github.com:void-linux/void-packages.git`. This allows you to
	run `git checkout master` and then `git pull --rebase upstream master` to
	bring your local master branch up to date with the master void linux
	repository. 


<h2 id="contributing">Contributing to Void Packages</h2>

make sure your local master is up to date, then start a new branch to make your
contributions in.


<h2 id="building">Building packages from source</h2>

1.	`cd` into local git repo of `void-packages` and run `./xbps-src
	binary-bootstrap`. This will initialize the packages necessary for building
	software.

2. 	To enable both custom contributions to void-packages, and building modified
	software with patches, use a separate git branch to actually build your
	custom packages from. I use a branch called `build-branch` created with
	`git checkout -b build-branch`. Whenever you want to build your custom
	software, checkout that branch first.

A side effect of using a custom `build-branch` is that all custom changes will
have full git history and can be easily applied without having to go through
all the effort of rebuilding the patch files.

patches are stored in `srcpkgs/<pkgname>/patches`


```tags
void-linux, void-packages, source, building
```
