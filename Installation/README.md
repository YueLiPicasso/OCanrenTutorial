# Installation

We install OCanren following the steps below. These steps constitute a precise record of 
what I did and what I saw when tring to install OCanren on a freshly installed, most recent (15 Oct 2020) ubuntu Linux. 
There are three sections: Summary, Sucessful Steps and Problems Begin.

## Summary
  
  Installation of OCanren failed because GT cannot be built. Then installation of GT failed because of unbound module Base, despite that 
  `opam install base` had installed base successfully.
 

## Successful Steps

OCanren depends on a particular version of OCaml which is _4.07.1+fp+flambda_. To install it and 
make it the current OCaml compiler, run in your terminal: 

`opam switch create 4.07.1+fp+flambda` 

 and follow the displayed instructions. It may take as long as 7 minutes.

Next we run: 

`opam pin add GT https://github.com/JetBrains-Research/GT.git -n -y` 

to make available the GT (Generic Transformer) package. GT provides a Haskell-typeclass-style
feature to OCaml, and is helpful if not indispensable for wriing OCanren code.  This step is very quick. 

Now we download the OCanren source package and install it locally. Run, in your directory of choice:

`git clone https://github.com/JetBrains-Research/OCanren.git ocanren && cd ocanren`

to get a local copy of the source. The above command also changes the working directory to the _ocanren_
 folder where the following commands will be run. 
 
 
## Problems Begin
  
 We install the OCanren dependencies by:

`opam install . --deps-only --yes` 

This would take some time. Then we are ready to install OCanren itself. First, run:

`make`

You may find that the `make` command failed, citing that "Package GT not found". Indeed, in this case the trace of the
dependency installation step would indicate a failure of building GT. To resolve this problem, we should try
 to install GT separately. In your directory of choice:
 
 `https://github.com/JetBrains-Research/GT`
 
 and then 
 
 `cd GT && make`. At this point an error message shows that the package "base" is not found, which we now install by:
 
 `opam install base`
 
 And we try `make` under the GT directory again. This time it shows that there is still unbound module Base. 
 
 Being confused, we move back to
 the ocanren directory and `make clean && make`. This time we were told that the command _ocamlbuild_ is not found.
 Curiously, running `opam install ocamlbuild` shows that this package has already been installed, but running `ocamlbuild`
 itself shows "command not found" againt, but this time prompts us to install it with `sudo apt install ocamlbuild`. So let's
  do it.
  
  Then back to ocanren directory and `make`. Failed again. Running `ocamlfind` gives: 
  
  "command 'ocamlfind' not found, but can be installed with: sudo apt install ocaml-findlib". We follow this and install
  ocaml-findlib.
  

 
   

 


