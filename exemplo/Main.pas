unit Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  email;

type
  TForm1 = class(TForm)
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    edtNomeCedente: TEdit;
    edtEmailCedente: TEdit;
    edtUsuario: TEdit;
    edtSenha: TEdit;
    edtServidor: TEdit;
    edtPorta: TEdit;
    ckbUtilizaSSL: TCheckBox;
    ckbUtilizaTSL: TCheckBox;
    Button2: TButton;
    EMail: TEMail;
    edtDestinatario: TEdit;
    edtTitulo: TEdit;
    edtMensagem: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    memStatus: TMemo;
    procedure Button2Click(Sender: TObject);
    procedure EMailError(const AError: string);
    procedure EMailStatus(const AStatus: string);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button2Click(Sender: TObject);
begin
  // Configurações
  EMail.Configuracoes.Email            := edtEmailCedente.Text;
  EMail.Configuracoes.NomeCedente      := edtNomeCedente.Text;
  EMail.Configuracoes.Porta            := edtPorta.Text;
  EMail.Configuracoes.Senha            := edtSenha.Text;
  EMail.Configuracoes.Servidor         := edtServidor.Text;
  EMail.Configuracoes.Usuario          := edtUsuario.Text;
  EMail.Configuracoes.UtilizaSSL       := ckbUtilizaSSL.Checked;
  EMail.Configuracoes.TipoProxy        := tpNenhum;
  EMail.Configuracoes.TipoAutenticacao := 1;

  if ckbUtilizaTSL.Checked then
    EMail.Configuracoes.UtilizaTLS := 1
  else
    EMail.Configuracoes.UtilizaTLS := 0;

  EMail.Anexos.Add('C:\temp\boleto.pdf');

  EMail.Enviar(edtDestinatario.Text, //Destinatário
               edtTitulo.Text,       // Título E-mail
               edtMensagem.Text);    // Mensagem E-mail
end;

procedure TForm1.EMailError(const AError: string);
begin
  memStatus.Lines.Add(AError);
end;

procedure TForm1.EMailStatus(const AStatus: string);
begin
  memStatus.Lines.Add(AStatus);
end;

end.
