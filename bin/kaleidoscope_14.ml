let () =
  let dest = ref `Stdin in
  Arg.parse
    [ "-file", Arg.String (fun s -> dest := `File s), " FILE read input from file" ]
    (fun _ -> failwith "Anonymous ones are not supported")
    "Parse and print kaleidoscope";
  Kaleidoscope_lib_14.Toplevel.main !dest
;;
