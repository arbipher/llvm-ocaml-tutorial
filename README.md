# llvm-ocaml-tutorial

The tutorial is tested up to OCaml 4.14.1 and LLVM 14.0.6.

## Build

```console
# Install the dependencies
opam install base ctypes-foreign llvm menhir ppx_jane

# Build the shared library
dune build stubs/libbindings.so

# Add the shared library to path
export LD_LIBRARY_PATH=_build/default/stubs
```

## Run

```console
dune exec bin/kaleidoscope.exe < example/mandel.kal
```

## Test

```console
dune test
```

## Meta

Thank to @Kakadu's PR.

The project is originally forked from https://github.com/adamrk/llvm-ocaml-tutorial.

