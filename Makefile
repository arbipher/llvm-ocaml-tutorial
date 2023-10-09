.PHONY : build-14 link-14 all-14 run-14 build link all run

# Check `README.md` for pre-requisite

# These are for LLVM < 15 and OCaml < 5

build-14 :
	dune build bin/kaleidoscope_14.exe

link-14 :
	rm -f k_14.exe
	ln -s _build/default/bin/kaleidoscope_14.exe k_14.exe

run-14 :
	LD_LIBRARY_PATH=_build/default/stubs ./k_14.exe

demo-14:
	dune exec bin/kaleidoscope_14.exe < example/mandel.ks

# These are for LLVM >= 15 and OCaml >= 5

build :
	dune build bin/kaleidoscope.exe

link :
	rm -f k.exe
	ln -s _build/default/bin/kaleidoscope.exe k.exe

run :
	LD_LIBRARY_PATH=_build/default/stubs ./k.exe

demo:
	dune exec bin/kaleidoscope.exe < example/mandel.ks

# Not covering yet

test:
	dune test lib

ch8-main:
	clang++ main.cpp output.o -o main

ch9-clang:
	LD_LIBRARY_PATH=_build/default/stubs ./k_14.exe < example/fib.ks 2>&1 | clang -x ir -

