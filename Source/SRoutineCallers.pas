unit SRoutineCallers;

interface

function CallThiscall(ClassRef, ProcRef: Pointer;
  Params: array of Longword): LongWord;

implementation

{ Call the Thiscall routine at "ProcRef", on the class instance "ClassRef", with
  the given params }
function CallThiscall(ClassRef, ProcRef: Pointer;
  Params: array of Longword): LongWord;
asm
  PUSH       EBX
  MOV        EBX,      [EBP+8]
  TEST       EBX,      EBX
  JS         @@ParamsDone

  LEA        ECX,      [ECX+EBX*4]
@@ParamLoop:
  PUSH       DWORD PTR [ECX]
  LEA        ECX,      [ECX-4]
  DEC        EBX
  JNS        @@ParamLoop

@@ParamsDone:
  MOV        ECX,      EAX
  CALL       EDX
  POP        EBX
end;

end.
