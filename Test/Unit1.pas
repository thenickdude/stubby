unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ASMInline, StdCtrls, SPatching, ASMTest;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure showNum(i: integer); stdcall;
begin
  showmessage(inttostr(i));
end;

procedure showNegNum(i: integer); stdcall;
begin
  showmessage(inttostr(-i));
end;

procedure myproc(i: integer);
begin
  ShowMessage(inttostr(i));
end;

procedure TForm1.Button1Click(Sender: TObject);
var inliner: TASMInline;
begin
  inliner := TASMInline.create;
  try

  finally
    inliner.free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
DoTests;
end;

end.

