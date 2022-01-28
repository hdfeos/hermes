# Hermes Docker Files

## deps.Dockerfile

Creates an image containing just the Hermes build dependencies. A spack view is
created at `~/install`.

## dev.Dockerfile

Includes all the dependencies, plus a clone of the Hermes repo on the `master`
branch (at time of image creation). A build script, `~/build_hermes.sh` is also
provided, which builds Hermes in `~/hermes/build`.

## user.Dockerfile

Includes a working installation of Hermes in `~/install`.
