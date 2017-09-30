# libffi tarballs for GHC

This repository contains the source tarballs used to
build [libffi](https://github.com/libffi/libffi/issues/296)
for [GHC](https://ghc.haskell.org/). While in principle this repository should
contain official source tarballs from the libffi project, the
recent [lack of releases](https://github.com/libffi/libffi/issues/296) has meant
that we have had to start packaging our own snapshots.

Note that in order to reduce working tree size, this repository contains only
orphan branches. Each branch contains one source tarball. These tarballs and
their branches are generated using the `mk-snapshot.sh` script.

In order to update the `libffi` version built by GHC, first run
`mk-snapshot.sh`, then push the resulting branch to `git.haskell.org`, and
finally update the submodule commit in the `ghc` repository.
