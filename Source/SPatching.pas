unit SPatching;

{ Provides tools for patching existing code at runtime.}

interface

uses sysutils,SCommon, windows, ASMInline,math;

function VMTLookup(obj: pointer; vmtOffset: cardinal): pointer;
function ClassProp(inst: pointer; prop: longword): pointer;

type
  TPatch = class
  protected
    fRestoreOnFree: boolean;
    fPatchSize: integer;
    fPatchSite: pointer;
    fPatchSiteSize:integer;
    fBackup: pointer;
    procedure MakeBackup; virtual;
    constructor Create(patchSiteSize:integer; RestoreOnFree: boolean = true); virtual;
  public
    procedure Patch; virtual;
    procedure RestoreBackup; virtual;
    destructor Destroy; override;
  end;

  {Root for classes that patch using the contents of a TASMInline'r}
  TCustomASMInlinePatch = class(TPatch)
  protected
    fASM: TASMInline;
    constructor Create(patchSite:pointer; patchSiteSize:integer=0; RestoreOnFree: boolean = true); reintroduce;
    procedure RenderToInliner(inliner:TASMInline); virtual; abstract; {Override this method to generate your code}
  public
    procedure Patch; override;
    destructor Destroy; override;
  end;

  TASMInlinePatch=class(TCustomASMInlinePatch)
  protected
    procedure RenderToInliner(inliner:TASMInline); override;
  public
    constructor Create(patchSite:pointer; patchSiteSize:integer=0; RestoreOnFree: boolean = true);
    property ASMCode:TASMInline read fASM;
  end;

  {At patch which inserts a jump or call to newProc at targetLoc.}
  TJumpPatch = class(TCustomASMInlinePatch)
  private
    fNewProc: pointer;
    fcall:boolean;
  protected
    procedure RenderToInliner(inliner:TASMInline); override;
  public
    constructor Create(targetLoc: pointer; newProc: pointer; call:boolean=false; RestoreOnFree: boolean = true); reintroduce;
  end;

implementation

constructor TASMInlinePatch.Create(patchSite:pointer; patchSiteSize:integer=0; RestoreOnFree: boolean = true);
begin
  inherited create(patchsite,patchsitesize,RestoreOnFree);
end;

procedure TASMInlinePatch.RenderToInliner(inliner:TASMInline);
begin
{No-op. User should fill the inliner themselves}
end;

destructor TCustomASMInlinePatch.Destroy;
begin
  inherited;
  fAsm.free;
end;

procedure TCustomASMInlinePatch.Patch;
begin
  fPatchSize:=fASM.Size;
  inherited;
  fASM.SaveToMemory(fPatchSite);    {THIS WHOLE PACKAGE IS BROKEN     }
end;

constructor TCustomASMInlinePatch.create(patchSite:pointer; patchSiteSize:integer=0; RestoreOnFree: boolean = true);
begin
  fPatchSite:=patchSite;
  fASM := TASMInline.create;
  RenderToInliner(fASM);
  inherited create(patchSiteSize,RestoreOnFree);
end;

procedure TJumpPatch.RenderToInliner(Inliner:TASMInline);
begin
  if fcall then
    inliner.Call(fNewProc)
  else
    inliner.Jmp(fNewProc);
end;

constructor TJumpPatch.Create(targetLoc: pointer; newProc: pointer; call:Boolean=false; RestoreOnFree: boolean = true);
begin
  fNewProc := newproc;
  fcall:=call;

  inherited create(targetLoc,0,RestoreOnFree);
end;


{Default implementation simply calls VirtualProtect to make the patchsite
 available for patching}
procedure TPatch.Patch;
var oldprotect: cardinal;
begin
  VirtualProtect(fPatchSite, max(fPatchSize,fpatchsiteSize), PAGE_EXECUTE_READWRITE, oldprotect);

  if fPatchSiteSize<>0 then begin //we specified a patch site size
    if fpatchsize>fPatchSiteSize then
     raise exception.create('Patch is larger than patch site!')
       else
      FillChar(ptr(integer(fPatchSite)+fPatchSize)^,fpatchsitesize-fpatchsize,$90); //nop
    end;
end;

procedure TPatch.MakeBackup;
begin
  GetMem(fBackup, fPatchSize);
  Move(fPatchSite^, fBackup^, fPatchSize);
end;

procedure TPatch.RestoreBackup;
begin
  Move(fBackup^, fPatchSite^, fPatchSize);
end;

constructor TPatch.Create(patchSiteSize:integer; RestoreOnFree: boolean);
begin
  fRestoreOnFree := RestoreOnFree;
  fPatchSiteSize:=patchSiteSize;
  MakeBackup;
  Patch;
end;

destructor TPatch.Destroy;
begin
  inherited;

  if (fBackup <> nil) then begin
    if fRestoreOnFree then
      RestoreBackup;
    FreeMem(fBackup);
  end;
end;

//Return the VMT entry with the given offset for the given object

function VMTLookup(obj: pointer; vmtOffset: cardinal): pointer;
begin
  result := PPointer(ptr(plongword(obj)^ + vmtOffset))^;
end;

function classprop(inst: pointer; prop: longword): pointer;
begin
  result := ptr(cardinal(inst) + prop);
end;

end.

