
## Build

```shell
# Install the dependencies
opam install base ctypes-foreign llvm menhir ppx_jane

# Build the shared library
dune build stubs/libbindings.so

# Add the shared library to path
export LD_LIBRARY_PATH=_build/default/stubs
```

## Run

`dune exec bin/kaleidoscope.exe < example/mandel.kal`

## Test

`dune test`

## Meta

Thank to @Kakadu's PR.

The project is originally forked from https://github.com/adamrk/llvm-ocaml-tutorial.

