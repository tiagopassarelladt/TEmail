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
  math,
  email, Vcl.ComCtrls, System.ImageList, Vcl.ImgList, Vcl.ExtCtrls;

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
    EMail: TEMail;
    imglist: TImageList;
    GroupBox5: TGroupBox;
    Remetente: TLabeledEdit;
    Destinatario: TLabeledEdit;
    comcopia: TLabeledEdit;
    Assunto: TLabeledEdit;
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    GroupBox4: TGroupBox;
    Mensagem: TMemo;
    btnAnexos: TButton;
    btnLimparAnexos: TButton;
    Button2: TButton;
    memStatus: TMemo;
    comcopiaoculta: TLabeledEdit;
    responderpara: TLabeledEdit;
    procedure btnAnexosClick(Sender: TObject);
    procedure btnLimparAnexosClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure EMailError(const AError: string);
    procedure EMailStatus(const AStatus: string);
  private
    { Private declarations }
    procedure AddItemsListview(Listview: TListView; Arquivo: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.AddItemsListview(Listview: TListView; Arquivo: string);
Var
  Items: TStringList;
  Item: TListItem;
  I: Integer;
begin
  Items := TStringList.Create;
  try
    Items.add (Arquivo ); //Items.LoadFromFile(Arquivo);
    for I := 0 to Items.Count -1 do begin
      Item := Listview.Items.Add;
      Item.Caption := Items[I]; // Coloca o valor na primeira coluna do Listview
    end;
  finally
    Items.Free;
  end;
end;

procedure TForm1.btnAnexosClick(Sender: TObject);
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

procedure TForm1.btnLimparAnexosClick(Sender: TObject);
begin
  case Application.MessageBox(PChar('Confirma limpar todos os anexos?'),
     PChar('TMail'), MB_YESNO + MB_ICONQUESTION + MB_DEFBUTTON2 + MB_TOPMOST) of
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
procedure TForm1.EMailError(const AError: string);
begin
  memStatus.Lines.Add(AError);
end;

procedure TForm1.EMailStatus(const AStatus: string);
begin
  memStatus.Lines.Add(AStatus);
end;

end.
