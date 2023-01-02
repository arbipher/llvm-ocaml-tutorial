  $ LD_LIBRARY_PATH=../stubs ./kaleidoscope.exe -file ../fib.ks
  ; ModuleID = 'main'
  source_filename = "main"
  target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
  target triple = "x86_64-pc-linux-gnu"
  
  define double @fib(double %x) {
  entry:
    %cmptmp = fcmp ult double %x, 3.000000e+00
    br i1 %cmptmp, label %ifcont, label %else
  
  else:                                             ; preds = %entry
    %subtmp = fadd double %x, -1.000000e+00
    %calltmp = call double @fib(double %subtmp)
    %subtmp5 = fadd double %x, -2.000000e+00
    %calltmp6 = call double @fib(double %subtmp5)
    %addtmp = fadd double %calltmp, %calltmp6
    br label %ifcont
  
  ifcont:                                           ; preds = %entry, %else
    %iftmp = phi double [ %addtmp, %else ], [ 1.000000e+00, %entry ]
    ret double %iftmp
  }
  
  define double @main() {
  entry:
    %calltmp = call double @fib(double 1.000000e+01)
    ret double %calltmp
  }
