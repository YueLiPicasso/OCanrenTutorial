# Installation

I give an overview of OCanren installation, then follows detailed
explanation of some steps. Note that glitches may occur, and
the flow of actions demonstrated below only _represents_ a typical successful installation.
Please raise an issue in case you meet any problem.

## Overview

Installation Sequence

- Linux OS
- opam >=2.0
- ocaml 4.07.1+fp+flambda
- ppxlib.0.13.0
- GT
- OCanren

Major Terminal Instructions

- Under any directory:
  - opam switch 4.07.1+fp+flambda
  - opam install GT

- Then under the ocanren directory:
  - make
  - make install

## Details

You shall have a computer running Linux, with Git, Opam and OCaml installed. Instructions for
installing Linux, Git, Opam and OCaml in general is out of the scope of this tutorial. I recommend
however the following points of reference:

- [Ubuntu Linux](https://ubuntu.com/)

- [Opam and OCaml installation](https://dev.realworldocaml.org/install.html)

- [Git](https://git-scm.com/)

When I give command line instructions below, I mean that the given instruction can be executed under
any directory, unless explicitly stated otherwise.

### Switching to the Right OCaml Compiler

OCanren depends on a particular version of OCaml which is _4.07.1+fp+flambda_. You can check
if it is already on your computer by running
```
opam switch
```
which lists all available OCaml compilers.

If it is there, but is not the current compiler, run:
```
opam switch 4.07.1+fp+flambda
eval $(opam env)
```
to make it the current compiler.

If it is not there, run:
```
opam switch create 4.07.1+fp+flambda
eval $(opam env)
```
to install it and consequently make it the current compiler.


### GT Installation

[GT (Generic Transformer)](https://github.com/JetBrains-Research/GT) provides a Haskell-typeclass-style
feature to OCaml, and is helpful if not indispensable for wriing OCanren code. To install
GT, run:
```
opam install ppxlib.0.13.0 
opam install GT
```

Youu may find it helpful to get a local copy of the GT source as well:
```
git clone https://github.com/JetBrains-Research/GT
```

### Obtaining and Building OCanren Source Code

Run in your directory of choice:
```
git clone https://github.com/JetBrains-Research/OCanren.git ocanren && cd ocanren
```
The command gets you a local copy of the OCanren source code and then changes
the working directory to it.


Afterwards, install other dependencies of OCanren by:
```
opam install . --deps-only --yes
```

Finally (avoid using `sudo` together with the following commands):
```
eval $(opam env)
make
make install
```

