unit SStubs;

interface

uses Sysutils, windows, ASMInline, SPatching;

type
  TStub = class
  public
    stub: pointer;
    destructor Destroy; override;
  end;

  {Note that you must declare your stubbed routine to receive an extra pointer
   as its first argument. This is the return address of your caller.

   This stub makes a Cdecl routine look like a thiscall method to a caller.}
  TCdeclAsThiscallStub = class(TStub)
  public
    constructor Create(targetProc:pointer);
  end;

 {Replace a Thiscall routine at origProc with a call to your new cdecl
  routine at newProc, destroying the original routine in the process.}
  TCdeclAsThiscallPatch = class(TPatch)
  private
    fNewProc: pointer;
    fASM: TASMInline;
  public
    destructor Destroy; override;
    constructor Create(origProc, newProc: pointer; RestoreOnFree: boolean = true); reintroduce;
    class procedure PermPatch(origProc, newProc:pointer);
    procedure Patch; override;
  end;

  {This stub makes a Stdcall method look like a Stdcall procedure to the caller}
  TStdcallMethodAsStdcallStub = class(TStub)
  public
    constructor Create(targetObj:pointer; targetProc:pointer);
  end;

implementation

constructor TStdcallMethodAsStdcallStub.Create(targetObj:pointer; targetProc:pointer);
var fASM:TASMInline;
begin
  fASM:=TASMInline.create;
  try
    fASM.Pop(EAX); // Pop the return address off the stack
    fASM.Push(cardinal(targetObj)); // Push the object pointer onto the stack
    fASM.Push(EAX); // Push the return address back on the stack
    fASM.Jmp(targetProc);

    stub:=fASM.SaveAsMemory;
  finally
    fasm.Free;
  end;
end;

constructor TCdeclAsThiscallStub.Create(targetProc:pointer);
var fASM:TASMInline;
begin
  fASM:=TASMInline.create;
  try
    fASM.Push(ecx); //Add the class ptr to the params list
    fASM.Call(targetProc);
    fASM.Pop(ecx); //Get rid of that extra class pointer
    fASM.Ret(); //Return to the caller
    stub:=fASM.SaveAsMemory;
  finally
    fASM.Free;
  end;
end;

destructor TCdeclAsThiscallPatch.destroy;
begin
  inherited;
  fASM.free;
end;

class procedure TCdeclAsThiscallPatch.PermPatch(origProc, newProc:pointer);
begin
 TCdeclAsThiscallPatch.Create(origProc,newProc,false).free;
end;

constructor TCdeclAsThiscallPatch.Create(origProc, newProc: pointer; RestoreOnFree: boolean = true);
begin
  fPatchSite := origProc;
  fNewProc := newProc;

  fASM := TASMInline.create;

  fASM.Push(ecx); //Add the class ptr to the params list
  fASM.Call(fNewProc);
  fASM.pop(ecx); //Get rid of that extra class pointer
  fASM.ret(); //Return to the caller

  inherited create(fASM.size, true);
end;

procedure TCdeclAsThiscallPatch.Patch;
begin
  inherited;

  fASM.SaveToMemory(fPatchSite);
end;

destructor TStub.destroy;
begin
  if stub<>nil then
    FreeMem(stub);
  inherited;
end;

function CreateStubCdeclAsThiscall(target: pointer): TStub;
var stub: TStub;
  asmin: TASMInline;
begin
  stub := tstub.create;
  asmin := TASMInline.create;
  try
    asmin.Push(ecx); //Add the class ptr to the params list
    asmin.Mov(eax, Cardinal(target));
    asmin.Call(eax);
    asmin.Pop(ecx); //Get rid of that extra class pointer
    asmin.Ret(); //Return to the caller

    stub.stub := asmin.SaveAsMemory;
  finally
    asmin.free;
  end;

  result := stub;
end;

end.

