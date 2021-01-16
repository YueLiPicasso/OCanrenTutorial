# Installation

We shall have a computer running Linux, with [Git](https://git-scm.com/)
and [Opam](https://opam.ocaml.org/) installed.
We then install the following:  

1. ocaml 4.07.1+fp+flambda
1. GT
1. Camlp5
1. OCanren

## Step 1: Swtching to the right OCaml compiler

OCanren depends on a particular version of OCaml which is _4.07.1+fp+flambda_. You can check
if it is already on your computer by running
```
opam switch
```
which lists all available OCaml compilers. If it is not there, run:
```
opam switch create 4.07.1+fp+flambda
eval $(opam env)
```
to install it and consequently make it the current compiler.

## Step 2:  Installing GT

[GT](https://github.com/JetBrains-Research/GT) provides
a Haskell typeclass style feature to OCaml, and is helpful if not indispensable for wriing OCanren code.
To install
GT, run:
```
opam install GT
```

**Note** Since GT is under active development, installation details of it may change. Please consult the project
webpage for the most updated instructions.

## Step 3: Installing Camlp5

We use [Camlp5](https://github.com/camlp5/camlp5) version 7.10. Newer versions like 7.12 and 8.00 are not 
compatible.  

## Step 4:  Installing OCanren

The [official OCanren](https://github.com/JetBrains-Research/OCanren.git) is
under active development. This tutorial includes a stable and minimal distribution. 
Change directory to [ocanren](./ocanren) and execute the following commands: 
```
eval $(opam env)
opam install . --deps-only --yes
make
make install
```

## To Uninstall OCanren:

Change directory to [ocanren](./ocanren) and execute the following commands:
```
make uninstall
make clean
```
