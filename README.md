# llvm-ocaml-tutorial

## Introduction

The tutorial is Kaleidoscope on OCaml. It's not intended as a fully translation of [LLVM Kaleidoscope tutorial](https://llvm.org/docs/tutorial/MyFirstLanguageFrontend/index.html), but a demonstration of basic LLVM APIs in OCaml.

The tutorial is tested with combinations of

1. opam `llvm.16+nnp` and OCaml 5.1.0 (should be released soon).
2. opam `llvm.14.0.6` and OCaml 4.14.1.

In opam packages, `llvm.16+nnp` uses _Opaque Pointers_ and `llvm.14.0.6` uses _Typed pointers_. In official LLVM, _Opaque Pointers_ are enabled by default from LLVM 15 and _Typed pointers_ are not supported from LLVM 17. See [LLVM Opaque Pointers](https://llvm.org/docs/OpaquePointers.html) for details.

## Build

Since the changes in LLVM is breakable but tiny in their APIs until now, for better or for worse, there is some duplicate code in the repo. Combination 1 uses `bin/kaleidoscope.ml` and `lib`. Combination 2 uses `bin/kaleidoscope.ml_14.ml` and `lib-14`. The rest are shared.

```console
# Install the dependencies
opam install base ctypes-foreign llvm menhir ppx_jane

# Build the shared library
dune build stubs/libbindings.so

# Add the shared library to path
export LD_LIBRARY_PATH=_build/default/stubs
```

## Run (Hurry)

```console
# with llvm 14.0.6
dune exec bin/kaleidoscope_14.exe < example/mandel.kal
```

```console
# with llvm 16+nnp or beyond
dune exec bin/kaleidoscope.exe < example/mandel.kal
```

## Run (Step-wise)

See `Makefile`.

```console
# with llvm 14.0.6
make build-14
make link-14
make demo-14
make run-14
```

```console
# with llvm 16+nnp or beyond
make build
make link
make demo
make run
```
## Meta

Currently, the difference between two version of code is tiny.

The result of `diff bin/kaleidoscope.ml bin/kaleidoscope_14`
```diff
7c7
<   Kaleidoscope_lib.Toplevel.main !dest
---
>   Kaleidoscope_lib_14.Toplevel.main !dest
```

The result of `diff lib lib-14`

```diff
diff '--color=auto' lib/codegen.ml lib-14/codegen.ml
57c57
<      | Some v -> Llvm.build_load double_type v name builder)
---
>      | Some v -> Llvm.build_load v name builder)
96,99c96
<        let fnty =
<          Llvm.function_type double_type (Array.of_list [ double_type; double_type ])
<        in
<        Llvm.build_call fnty callee [| lhs_val; rhs_val |] "binop" builder)
---
>        Llvm.build_call callee [| lhs_val; rhs_val |] "binop" builder)
112,114c109
<     let arg_typs = Array.map args ~f:(Fn.const double_type) in
<     let fnty = Llvm.function_type double_type arg_typs in
<     Llvm.build_call fnty callee args "calltmp" builder
---
>     Llvm.build_call callee args "calltmp" builder
211c206
<     let cur_var = Llvm.build_load double_type alloca var_name builder in
---
>     let cur_var = Llvm.build_load alloca var_name builder in
237,238c232
<     let fnty = Llvm.function_type double_type (Array.of_list [ double_type ]) in
<     Llvm.build_call fnty callee [| operand |] "unop" builder
---
>     Llvm.build_call callee [| operand |] "unop" builder
diff '--color=auto' lib/dune lib-14/dune
2c2
<  (name kaleidoscope_lib)
---
>  (name kaleidoscope_lib_14)
```

Thank to @Kakadu's PR.

The project is originally forked from https://github.com/adamrk/llvm-ocaml-tutorial.

## Todo

- [ ] Redo testing.
- [ ] Use vanilla library instead of `Base`.
- [ ] Update the missing part of the official Kaleidoscope tutorial.
- [ ] Rewrite the tutorial in OCaml.
