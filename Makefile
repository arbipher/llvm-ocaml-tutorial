.PHONY : build link all run

build :
	dune build bin/kaleidoscope.exe

link :
	rm -f k.exe
	ln -s _build/default/bin/kaleidoscope.exe k.exe

all: build link

run :
	LD_LIBRARY_PATH=_build/default/stubs ./k.exe

ch8-main:
	clang++ main.cpp output.o -o main

ch9-clang:
	LD_LIBRARY_PATH=_build/default/stubs ./k.exe < fib.ks 2>&1 | clang -x ir -

