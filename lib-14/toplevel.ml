open Base
open Lang_ks

let dump_to_object ~the_fpm =
  Llvm_all_backends.initialize ();
  (* "x86_64-pc-linux-gnu" *)
  let target_triple = Llvm_target.Target.default_triple () in
  let target = Llvm_target.Target.by_triple target_triple in
  let cpu = "generic" in
  let reloc_mode = Llvm_target.RelocMode.Default in
  let machine =
    Llvm_target.TargetMachine.create ~triple:target_triple ~cpu ~reloc_mode target
  in
  let data_layout =
    Llvm_target.TargetMachine.data_layout machine |> Llvm_target.DataLayout.as_string
  in
  Llvm.set_target_triple target_triple Codegen.the_module;
  Llvm.set_data_layout data_layout Codegen.the_module;
  let filename = "output.o" in
  Llvm_target.TargetMachine.add_analysis_passes the_fpm machine;
  let file_type = Llvm_target.CodeGenFileType.ObjectFile in
  Llvm_target.TargetMachine.emit_to_file Codegen.the_module file_type filename machine;
  (* printf "Wrote %s\n" filename; *)
  ()
;;

let run_main in_channel ~the_fpm ~the_execution_engine =
  let anonymous_func_count = ref 0 in
  let supplier =
    Parser.MenhirInterpreter.lexer_lexbuf_to_supplier
      Lexer.read
      (Lexing.from_channel in_channel)
  in
  let rec run_loop the_fpm the_execution_engine supplier =
    let incremental = Parser.Incremental.toplevel Lexing.dummy_pos in
    (* printf "\n" ;
       printf "ready> " ; *)
    Out_channel.flush Stdio.stdout;
    (try
       match Parser.MenhirInterpreter.loop supplier incremental with
       | `Expr ast ->
         (* printf "parsed a toplevel expression" ; *)
         (* Evaluate a top-level expression into an anonymous function. *)
         let func = Ast.func_of_no_binop_func ast in
         Out_channel.flush Stdio.stdout;
         Llvm_executionengine.add_module Codegen.the_module the_execution_engine;
         anonymous_func_count := !anonymous_func_count + 1;
         let _tmp_name = Printf.sprintf "__toplevel%d" !anonymous_func_count in
         let tmp_func = Ast.set_func_name "main" func in
         let _the_function = Codegen.codegen_func the_fpm tmp_func in
         ()
         (* Llvm.dump_value the_function ;
              (* JIT the function, returning a function pointer. *)
              let fp =
                Llvm_executionengine.get_function_address tmp_name
                  (Foreign.funptr Ctypes.(void @-> returning double))
                  the_execution_engine
              in
              printf "Evaluated to %f" (fp ()) ;
              Llvm_executionengine.remove_module Codegen.the_module
                the_execution_engine *)
       | `Extern ext ->
         (* printf "parsed an extern" ;
              printf !"%{sexp: Ast.proto}\n" ext; *)
         Out_channel.flush Stdio.stdout;
         let _code = Codegen.codegen_proto ext in
         ()
         (* Llvm.dump_value (Codegen.codegen_proto ext) *)
       | `Def def ->
         (* printf "parsed a definition" ; *)
         let func = Ast.func_of_no_binop_func def in
         (* printf !"%{sexp: Ast.func}\n" func; *)
         Out_channel.flush Stdio.stdout;
         let _code = Codegen.codegen_func the_fpm func in
         ()
         (* Llvm.dump_value code *)
       | `Eof ->
         (* printf "\n\n" ;
            printf "reached eof\n" ; *)
         (* printf "module dump:\n" ; *)
         Out_channel.flush Out_channel.stdout;
         (* Add ch8 *)
         dump_to_object ~the_fpm;
         (* Print out all the generated code. *)
         Llvm.dump_module Codegen.the_module;
         Stdlib.exit 0
     with
     | e ->
       (* Skip expression for error recovery. *)
       Stdlib.Printf.printf !"\nencountered an error %{sexp: exn}" e);
    Out_channel.flush Out_channel.stdout;
    run_loop the_fpm the_execution_engine supplier
  in
  run_loop the_fpm the_execution_engine supplier
;;

let main input =
  (* Install standard binary operators.
   * 1 is the lowest precedence. *)
  Hashtbl.add_exn Ast.binop_precedence ~key:'=' ~data:2;
  Hashtbl.add_exn Ast.binop_precedence ~key:'<' ~data:10;
  Hashtbl.add_exn Ast.binop_precedence ~key:'+' ~data:20;
  Hashtbl.add_exn Ast.binop_precedence ~key:'-' ~data:20;
  Hashtbl.add_exn Ast.binop_precedence ~key:'*' ~data:40;
  (* Create the JIT *)
  let the_execution_engine =
    (match Llvm_executionengine.initialize () with
     | true -> ()
     | false -> raise_s [%message "failed to initialize"]);
    Llvm_executionengine.create Codegen.the_module
  in
  let the_fpm = Llvm.PassManager.create_function Codegen.the_module in
  (* Promote allocas to registers. *)
  Llvm_scalar_opts.add_memory_to_register_promotion the_fpm;
  (* Do simple "peephole" optimizations and bit-twiddling optzn. *)
  Llvm_scalar_opts.add_instruction_combination the_fpm;
  (* reassociate expressions. *)
  Llvm_scalar_opts.add_reassociation the_fpm;
  (* Eliminate Common SubExpressions. *)
  Llvm_scalar_opts.add_gvn the_fpm;
  (* Simplify the control flow graph (deleting unreachable blocks, etc). *)
  Llvm_scalar_opts.add_cfg_simplification the_fpm;
  Llvm.PassManager.initialize the_fpm |> ignore;
  match input with
  | `Stdin -> run_main ~the_execution_engine ~the_fpm In_channel.stdin
  | `File file -> In_channel.with_open_text file (run_main ~the_execution_engine ~the_fpm)
;;
