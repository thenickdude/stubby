unit ASMTest;

{Unit for verifying generated code against Delphi exemplars

You should assemble RET as your last instruction so that the check will make sure
that the exemplar's code isn't longer than the code assembled by the Inliner
}

interface

uses sysutils, Dialogs,ASMInline;

procedure TestNOT;
procedure TestSHL;
procedure TestSHR;
procedure TestSAR;
procedure TestMOV;
procedure TestLabelsAndJumps;

//Test everything
procedure DoTests;

implementation

//verify the code in the inliner against the exemplar function

procedure Verify(inliner: TASMInline; exemplar: pointer; const name: string);
var mem:Pointer;
begin
  mem:=inliner.SaveAsMemory;
  try
  if not CompareMem(mem, exemplar, inliner.size) then
    raise Exception.create('Instruction ''' + name + ''' fails verification!');
  finally
    freemem(mem);
  end;
end;

procedure SHLExemplar;
asm
 shl bl,1
 shl bl,2
 shl bl,cl

 shl bx,1
 shl bx,2
 shl bx,cl
 
 shl ebx,1
 shl ebx,2
 shl ebx,CL

 SHL DWORD PTR [EBX], 1
 SHL DWORD PTR [EBX], 2
 SHL DWORD PTR [EBX], CL

 SHL WORD PTR [EBX], 1
 SHL WORD PTR [EBX], 2
 SHL WORD PTR [EBX], CL

 SHL BYTE PTR [EBX], 1
 SHL BYTE PTR [EBX], 2
 SHL BYTE PTR [EBX], CL
end;

procedure TestSHL;
var a: TASMInline;
begin
  a := TASMInline.create;
  try
    a.doSHL(bl, 1);
    a.doSHL(bl, 2);
    a.doSHL(bl, CL);

    a.doSHL(bx, 1);
    a.doSHL(bx, 2);
    a.doSHL(bx, CL);

    a.doSHL(ebx, 1);
    a.doSHL(ebx, 2);
    a.doSHL(ebx, CL);

    a.doSHL(a.addr(EBX), 1);
    a.doSHL(a.addr(EBX), 2);
    a.doSHL(a.addr(EBX), CL);

    a.doSHL(a.addr(EBX, ms16), 1);
    a.doSHL(a.addr(EBX, ms16), 2);
    a.doSHL(a.addr(EBX, ms16), CL);

    a.doSHL(a.addr(EBX, ms8), 1);
    a.doSHL(a.addr(EBX, ms8), 2);
    a.doSHL(a.addr(EBX, ms8), CL);

    a.ret;

    verify(a, @SHLExemplar, 'SHL');
  finally
    a.free;
  end;
end;

procedure SHRExemplar;
asm
 SHR bl,1
 SHR bl,2
 SHR bl,cl

 SHR bx,1
 SHR bx,2
 SHR bx,cl

 SHR ebx,1
 SHR ebx,2
 SHR ebx,CL

 SHR DWORD PTR [EBX], 1
 SHR DWORD PTR [EBX], 2
 SHR DWORD PTR [EBX], CL

 SHR WORD PTR [EBX], 1
 SHR WORD PTR [EBX], 2
 SHR WORD PTR [EBX], CL

 SHR BYTE PTR [EBX], 1
 SHR BYTE PTR [EBX], 2
 SHR BYTE PTR [EBX], CL
end;

procedure TestSHR;
var a: TASMInline;
begin
  a := TASMInline.create;
  try
    a.doSHR(bl, 1);
    a.doSHR(bl, 2);
    a.doSHR(bl, CL);

    a.doSHR(bx, 1);
    a.doSHR(bx, 2);
    a.doSHR(bx, CL);

    a.doSHR(ebx, 1);
    a.doSHR(ebx, 2);
    a.doSHR(ebx, CL);

    a.doSHR(a.addr(EBX), 1);
    a.doSHR(a.addr(EBX), 2);
    a.doSHR(a.addr(EBX), CL);

    a.doSHR(a.addr(EBX, ms16), 1);
    a.doSHR(a.addr(EBX, ms16), 2);
    a.doSHR(a.addr(EBX, ms16), CL);

    a.doSHR(a.addr(EBX, ms8), 1);
    a.doSHR(a.addr(EBX, ms8), 2);
    a.doSHR(a.addr(EBX, ms8), CL);

    a.ret;

    verify(a, @SHRExemplar, 'SHR');
  finally
    a.free;
  end;
end;

procedure SARExemplar;
asm
 SAR bl,1
 SAR bl,2
 SAR bl,cl

 SAR bx,1
 SAR bx,2
 SAR bx,cl

 SAR ebx,1
 SAR ebx,2
 SAR ebx,CL

 SAR DWORD PTR [EBX], 1
 SAR DWORD PTR [EBX], 2
 SAR DWORD PTR [EBX], CL

 SAR WORD PTR [EBX], 1
 SAR WORD PTR [EBX], 2
 SAR WORD PTR [EBX], CL

 SAR BYTE PTR [EBX], 1
 SAR BYTE PTR [EBX], 2
 SAR BYTE PTR [EBX], CL
end;

procedure TestSAR;
var a: TASMInline;
begin
  a := TASMInline.create;
  try
    a.SAR(bl, 1);
    a.SAR(bl, 2);
    a.SAR(bl, CL);

    a.SAR(bx, 1);
    a.SAR(bx, 2);
    a.SAR(bx, CL);

    a.SAR(ebx, 1);
    a.SAR(ebx, 2);
    a.SAR(ebx, CL);

    a.SAR(a.addr(EBX), 1);
    a.SAR(a.addr(EBX), 2);
    a.SAR(a.addr(EBX), CL);

    a.SAR(a.addr(EBX, ms16), 1);
    a.SAR(a.addr(EBX, ms16), 2);
    a.SAR(a.addr(EBX, ms16), CL);

    a.SAR(a.addr(EBX, ms8), 1);
    a.SAR(a.addr(EBX, ms8), 2);
    a.SAR(a.addr(EBX, ms8), CL);

    a.ret;

    verify(a, @SARExemplar, 'SAR');
  finally
    a.free;
  end;
end;

procedure MOVExemplar;
asm
  mov ecx,ebx
  mov cx, bx
  mov cl, bl

  mov [ecx],ebx
  mov ecx,[ebx]

  mov ebx, [ecx*4+123]

  mov DWORD PTR [ecx],ebx
  mov WORD PTR [ecx],bx
  mov BYTE PTR [ecx],BL

  mov EBX, DWORD PTR [ecx]
  mov BX, WORD PTR [ecx]
  mov BL, BYTE PTR [ecx]

  mov DWORD PTR [ecx],123
  mov DWORD PTR [ecx],123
  mov WORD PTR [ecx],123
  mov BYTE PTR [ecx],123

  mov ecx,4
  mov cx,4
  mov cl,4
end;

procedure TestMOV;
var a: TASMInline;
begin
  a := TASMInline.create;
  try
    a.MOV(ecx, ebx);
    a.MOV(cx, bx);
    a.Mov(cl, bl);

    a.MOV([ecx], ebx);
    a.MOV(ecx, [ebx]);

    a.mov(ebx, a.addr(123, ecx, 4));

    a.mov(a.addr(ecx), ebx);
    a.mov(a.addr(ecx, ms16), bx);
    a.mov(a.addr(ecx, ms8), bl);

    a.mov(ebx, a.addr(ecx));
    a.mov(bx, a.addr(ecx, ms16));
    a.mov(bl, a.addr(ecx, ms8));


    a.mov([ecx], 123);
    a.Mov(a.addr(ecx), 123);
    a.Mov(a.addr(ecx, ms16), 123);
    a.Mov(a.addr(ecx, ms8), 123);

    a.MOV(ecx, 4);
    a.Mov(cx, 4);
    a.MOV(cl, 4);

    a.ret;

    verify(a, @MOVExemplar, 'MOV');
  finally
    a.free;
  end;
end;

procedure NOTExemplar;
asm
 NOT EBX
 NOT BX
 NOT BL

 NOT DWORD PTR [EBX]
 NOT WORD PTR [EBX]
 NOT BYTE PTR [EBX]
end;

procedure TestNOT;
var a: TASMInline;
begin
  a := TASMInline.create;
  try
    a.doNot(ebx);
    a.doNot(bx);
    a.doNot(bl);

    a.doNot(a.addr(ebx));
    a.doNot(a.addr(ebx, ms16));
    a.doNot(a.addr(ebx, ms8));

    a.ret;

    verify(a, @NOTExemplar, 'NOT');
  finally
    a.free;
  end;
end;

procedure LabelsAndJumpsExemplar;
label a,b,c,d;
asm
 c:
 a:
 jmp a
 jmp b
 b:
 nop
 jmp c
 nop
 jmp d
 nop
 d:
end;

procedure TestLabelsAndJumps;
//var a: TASMInline;
begin
(*  a := TASMInline.create;
  try
    a.doLabel('c');
    a.doLabel('a');
    a.jmp('a');
    a.Jmp('b');
    a.dolabel('b');
    a.nop;
    a.Jmp('c');
    a.nop;
    a.Jmp('d');
    a.nop;
    a.dolabel('d');

    a.ret;

    verify(a, @LabelsAndJumpsExemplar, 'LabelsAndJumps');
  finally
    a.free;
  end;      *)
end;


//Test everything

procedure DoTests;
begin
  TestSHL;
  TestSHR;
  TestSAR;
  TestMOV;
  TestNOT;
  TestLabelsAndJumps;
  showmessage('Finished testing.');
end;



end.

