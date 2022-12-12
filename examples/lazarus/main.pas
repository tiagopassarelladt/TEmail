unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  LCLType, DateUtils ,StrUtils, math, Buttons, email, WinInet, ShellAPI, typinfo;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    Assunto: TLabeledEdit;
    ckbUtilizaSSL: TCheckBox;
    ckbUtilizaTSL: TCheckBox;
    comcopia: TLabeledEdit;
    comcopiaoculta: TLabeledEdit;
    Destinatario: TLabeledEdit;
    edtEmailCedente: TEdit;
    edtNomeCedente: TEdit;
    edtPorta: TEdit;
    edtSenha: TEdit;
    edtServidor: TEdit;
    edtUsuario: TEdit;
    EMail: TEMail;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Image1: TImage;
    imglist: TImageList;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ListBox1: TListBox;
    memStatus: TMemo;
    Mensagem: TMemo;
    Remetente: TLabeledEdit;
    responderpara: TLabeledEdit;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    procedure EMailError(const AError: string);
    procedure EMailStatus(const AStatus: string);
    procedure Image1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.Label1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://github.com/fraurino/', '', '', 1);
end;

procedure TfrmMain.SpeedButton1Click(Sender: TObject);
var
 a : Integer;
 opend : TOpenDialog;
begin
 opend := topendialog.Create(self);
  try
    opend.Title       := 'Selecione o(s) anexos(s)';
    opend.DefaultExt  := '*.pdf';
    opend.Filter      := 'Arquivos PDF (*.pdf)|*.pdf| Todos arquivos (*.*)|*.*';
    opend.Options     := [ofHideReadOnly,ofAllowMultiSelect,ofEnableSizing];
    if opend.Execute Then
    begin
     for a := 0 to opend.Files.Count - 1 do
     begin
      EMail.Anexos.Add(opend.Files.Strings[a]);
      ListBox1.Items.Add( ExtractFileName(opend.Files.Strings[a]));
     end;
    end;
  finally
   FreeAndNil(opend);
  end;
end;

procedure TfrmMain.SpeedButton2Click(Sender: TObject);
begin
    case Application.MessageBox(PChar('Confirma limpar todos os anexos?'),
     PChar('TMail'), MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2 ) of
     IDYES:
       begin
          email.anexos.Clear;
          ListBox1.Clear;
       end;
     IDNO:
       begin
          self.SetFocus;
       end;
   end;
end;

procedure TfrmMain.SpeedButton3Click(Sender: TObject);
begin
 // Configurações
  EMail.Configuracoes.Email            := edtEmailCedente.Text;
  EMail.Configuracoes.NomeCedente      := edtNomeCedente.Text;
  EMail.Configuracoes.Porta            := edtPorta.Text;
  EMail.Configuracoes.Senha            := edtSenha.Text;
  EMail.Configuracoes.Servidor         := edtServidor.Text;
  EMail.Configuracoes.Usuario          := edtUsuario.Text;
  EMail.Configuracoes.UtilizaSSL       := ckbUtilizaSSL.Checked;
  EMail.Configuracoes.UtilizaTLS       := math.IfThen(ckbUtilizaTSL.Checked, 1,0);
  EMail.Configuracoes.TipoProxy        := tpNenhum;
  EMail.Configuracoes.TipoAutenticacao := 1;

 // EMail.Anexos.Add('C:\temp\boleto.pdf');

  EMail.Enviar(Destinatario.Text,     // Destinatário
               Assunto.Text,          // Título E-mail
               Mensagem.Text,         // Mensagem E-mail
               comcopia.Text,         // email com copia
               comcopiaoculta.Text,   // email com copia oculta
               responderpara.Text     // email responder para diferente do remetente
               );
end;


procedure TfrmMain.Image1Click(Sender: TObject);
begin
   ShellExecute(Handle, 'open', 'https://github.com/tiagopassarelladt/TEmail  ', '', '', 1);
end;

procedure TfrmMain.EMailError(const AError: string);
begin
    memStatus.Lines.Add(AError);
end;

procedure TfrmMain.EMailStatus(const AStatus: string);
begin
    memStatus.Lines.Add(AStatus);
end;

end.

