program StubbyTest;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  ASMInline in '..\Source\ASMInline.pas',
  ASMTest in '..\Source\ASMTest.pas',
  SCommon in '..\Source\SCommon.pas',
  SPatching in '..\Source\SPatching.pas',
  SRoutineCallers in '..\Source\SRoutineCallers.pas',
  SStubs in '..\Source\SStubs.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
