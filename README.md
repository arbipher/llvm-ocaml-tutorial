## Meta

The project is forked from https://github.com/adamrk/llvm-ocaml-tutorial.

## Build

`opam install core async ctypes-foreign llvm menhir`

`export LD_LIBRARY_PATH=/path/to/libbindings.so`

The path is `_build/default/stubs/libbindings.so` by default.

## Run

`./path/to/bin/kaleidoscope.exe < example/mandel.kal`