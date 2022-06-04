unit email;

interface
  uses
    System.Classes,
    System.SysUtils,
    System.RegularExpressions,
    System.Generics.Collections,

    IdExplicitTLSClientServerBase,
    IdSMTP,
    IdSSLOpenSSL,
    IdConnectThroughHttpProxy,
    IdText,
    IdComponent,
    IdTCPConnection,
    IdTCPClient,
    IdMessageClient,
    IdSMTPBase,
    IdBaseComponent,
    IdIOHandler,
    IdIOHandlerSocket,
    IdIOHandlerStack,
    IdSSL,
    IdSocks,
    IdMessage,
    IdAttachmentFile;

type
  TTipoProxy = (tpNenhum, tpSocket, tpHttp);

  TBeforeExecute = procedure of object;
  TAfterExecute  = procedure of object;
  TOnError       = procedure(const AError: string) of object;
  TOnStatus      = procedure(const AStatus: string) of object;

  TConfiguracoes = class(TPersistent)
  private
    FEnderecoServidor: String;
    FEmail           : String;
    FSenhaProxy      : String;
    FUsuarioProxy    : String;
    FPortaProxy      : Integer;
    FUtilizaSSL      : Boolean;
    FTipoProxy       : TTipoProxy;
    FSenha           : String;
    FUtilizaTLS      : Integer;
    FServidorProxy   : String;
    FTipoAutenticacao: Integer;
    FUsuario         : String;
    FPortaServidor   : String;
    FNomeCedente     : string;

    function GetUtilizaSSL: Boolean;
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Servidor         : String      read FEnderecoServidor  write FEnderecoServidor;
    property Porta            : String      read FPortaServidor     write FPortaServidor;
    property Email            : String      read FEmail             write FEmail;
    property Usuario          : String      read FUsuario           write FUsuario;
    property Senha            : String      read FSenha             write FSenha;
    property NomeCedente      : string      read FNomeCedente       write FNomeCedente;
    property UtilizaSSL       : Boolean     read GetUtilizaSSL      write FUtilizaSSL;
    property UtilizaTLS       : Integer     read FUtilizaTLS        write FUtilizaTLS;
    property TipoAutenticacao : Integer     read FTipoAutenticacao  write FTipoAutenticacao;
    property ServidorProxy    : String      read FServidorProxy     write FServidorProxy;
    property PortaProxy       : Integer     read FPortaProxy        write FPortaProxy;
    property UsuarioProxy     : String      read FUsuarioProxy      write FUsuarioProxy;
    property SenhaProxy       : String      read FSenhaProxy        write FSenhaProxy;
    property TipoProxy        : TTipoProxy  read FTipoProxy         write FTipoProxy;
  end;

  TEMail = class(TComponent)
  private
    FConfiguracoes: TConfiguracoes;
    FAnexos       : TStringList;
    FOnStatus     : TOnStatus;
    FOnError      : TOnError;
    FVersao       : string;
    FSobre        : string;
    procedure SetConfiguracoes(const Value: TConfiguracoes);
  strict private
    FStatus: string;
    FError : string;

    procedure MontarImagensEmail(const AIdMessage: TIdMessage);
    procedure SetStatus(const AStatus: string);
    procedure SetError(const AError: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Anexos : TStringList read FAnexos write FAnexos;
    procedure Enviar(const AEmailDestinatario: string; const ATitulo: string; const AMensagem : WideString);

    function GetStatus: string;
    function GetError: string;
  published
    property Configuracoes: TConfiguracoes read FConfiguracoes write SetConfiguracoes;

    property Versao : string read FVersao;
    property Sobre  : string read FSobre;

    property OnStatus: TOnStatus read FOnStatus write FOnStatus;
    property OnError : TOnError  read FOnError  write FOnError;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('InoveFast', [TEMail]);
end;

procedure TConfiguracoes.Assign(Source: TPersistent);
begin
  inherited;
  if (Source is TConfiguracoes) then
    Exit;
end;

constructor TEMail.Create(AOwner: TComponent);
begin
  inherited;
  FConfiguracoes:= TConfiguracoes.Create;
  FAnexos       := TStringList.Create;
  Self.FVersao  := '1.5.1';
  Self.FSobre   := 'www.inovefast.com.br';
end;

destructor TEMail.Destroy;
begin
  if Assigned(FConfiguracoes) then
    FreeAndNil(FConfiguracoes);

  if Assigned(FAnexos) then
    FreeAndNil(FAnexos);

  inherited;
end;

procedure TEMail.Enviar(const AEmailDestinatario: string; const ATitulo: string; const AMensagem : WideString);
var
  FSMTP : TIdSMTP;
  FIdSSLIOHandlerSocketOpenSSL: TIdSSLIOHandlerSocketOpenSSL;
  FIdConnectThroughHttpProxy  : TIdConnectThroughHttpProxy;
  FIdText                     : TIdText;
  FIdMensagem                 : TIdMessage;
  FIdAttachmentFile           : TIdAttachmentFile;
  FIdSocksInfo                : TIdSocksInfo;
  FArquivo                    : string;
begin
  SetStatus('Iniciando');

  FSMTP                        := nil;
  FIdSSLIOHandlerSocketOpenSSL := nil;
  FIdConnectThroughHttpProxy   := nil;
  FIdText                      := nil;
  FIdMensagem                  := nil;
  FIdAttachmentFile            := nil;
  FIdSocksInfo                 := nil;
  try
    FSMTP := TIdSMTP.Create(nil);
    FIdSSLIOHandlerSocketOpenSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
    FIdSSLIOHandlerSocketOpenSSL.SSLOptions.Method := sslvTLSv1;
    FIdSSLIOHandlerSocketOpenSSL.SSLOptions.Mode   := sslmUnassigned;
    FIdSSLIOHandlerSocketOpenSSL.ReadTimeout       := 60000;

    FSMTP.Host     := Self.Configuracoes.Servidor;
    FSMTP.Username := Self.Configuracoes.Usuario;
    FSMTP.Password := Self.Configuracoes.Senha;
    FSMTP.Port     := Self.Configuracoes.Porta.ToInteger;
    FSMTP.AuthType := TIdSMTPAuthenticationType(Self.Configuracoes.TipoAutenticacao);
    FSMTP.ValidateAuthLoginCapability := False;

    if Self.Configuracoes.UtilizaSSL then
    begin
      FIdSSLIOHandlerSocketOpenSSL.SSLOptions.Method := sslvSSLv23;
      FIdSSLIOHandlerSocketOpenSSL.SSLOptions.Mode  := sslmClient;
      FSMTP.IOHandler := FIdSSLIOHandlerSocketOpenSSL;
      FSMTP.UseTLS    := TIdUseTLS(Self.Configuracoes.UtilizaTLS);
    end;

    FSMTP.ConnectTimeout := 60000;

    if (Self.Configuracoes.ServidorProxy <> EmptyStr) and
       (Self.Configuracoes.PortaProxy > 0)            and
       (Self.Configuracoes.UsuarioProxy <> EmptyStr)  and
       (Self.Configuracoes.SenhaProxy <> EmptyStr)    then
    begin
      case Self.Configuracoes.TipoProxy of
        tpSocket:
          begin
            FIdSocksInfo := TIdSocksInfo.Create;
            FIdSocksInfo.Host     := Self.Configuracoes.ServidorProxy;
            FIdSocksInfo.Port     := Self.Configuracoes.PortaProxy;
            FIdSocksInfo.Username := Self.Configuracoes.UsuarioProxy;
            FIdSocksInfo.Password := Self.Configuracoes.SenhaProxy;
            FIdSocksInfo.Enabled  := True;
            FIdSSLIOHandlerSocketOpenSSL.TransparentProxy := FIdSocksInfo;
          end;
        tpHttp:
          begin
            FIdConnectThroughHttpProxy := TIdConnectThroughHttpProxy.Create(Self);
            FIdConnectThroughHttpProxy.Host     := Self.Configuracoes.ServidorProxy;
            FIdConnectThroughHttpProxy.Port     := Self.Configuracoes.PortaProxy;
            FIdConnectThroughHttpProxy.Username := Self.Configuracoes.UsuarioProxy;
            FIdConnectThroughHttpProxy.Password := Self.Configuracoes.SenhaProxy;
            FIdConnectThroughHttpProxy.Enabled  := True;
            FIdSSLIOHandlerSocketOpenSSL.TransparentProxy := FIdConnectThroughHttpProxy;
          end;
      end;
    end;

    FIdMensagem := TIdMessage.Create(nil);

    FIdMensagem.ContentType               := 'multipart/mixed';
    FIdMensagem.Priority                  := mpNormal;
    FIdMensagem.From.Address              := Self.Configuracoes.Email;
    FIdMensagem.From.Name                 := Self.Configuracoes.NomeCedente;
    FIdMensagem.ReplyTo.EMailAddresses    := FIdMensagem.From.Address;
    FIdMensagem.Recipients.EMailAddresses := AEmailDestinatario;
    FIdMensagem.Subject                   := ATitulo;
    FIdMensagem.Body.Text                 := AMensagem;

    FIdText := TIdText.Create(FIdMensagem.MessageParts, FIdMensagem.Body);
    FIdText.ContentType := 'text/html';
    Self.MontarImagensEmail(FIdMensagem);

    for FArquivo in Self.Anexos do
    begin
      if not FileExists(FArquivo) then
        raise Exception.Create('Anexo ' + FArquivo +' não encontrado');

      FIdAttachmentFile := TIdAttachmentFile.Create(FIdMensagem.MessageParts, FArquivo);
    end;

    try
      if not FSMTP.Connected then
      begin
        SetStatus('Conectando ao serviço de e-mail');

        FSMTP.Connect;

        SetStatus('Autenticando e-mail');

        FSMTP.Authenticate;
      end;
    except
      on E:Exception do
      begin
        SetError(E.Message);
        raise Exception.Create(E.Message);
      end;
    end;
    try
      SetStatus('Enviando e-mail');

      FSMTP.Send(FIdMensagem);

      SetStatus('E-mail enviado');
    except
      on E:Exception do
      begin
        SetError(E.Message);
        raise Exception.Create(E.Message);
      end;
    end;
  finally
    SetStatus('Desconectando do serviço de e-mail');

    if FSMTP.Connected then
      FSMTP.Disconnect(True);

    if Assigned(FIdSSLIOHandlerSocketOpenSSL) then
      FreeAndNil(FIdSSLIOHandlerSocketOpenSSL);

    if Assigned(FIdConnectThroughHttpProxy) then
      FreeAndNil(FIdConnectThroughHttpProxy);

    if Assigned(FIdText) then
      FreeAndNil(FIdText);

    if Assigned(FIdMensagem) then
      FreeAndNil(FIdMensagem);

    if Assigned(FIdSocksInfo) then
      FreeAndNil(FIdSocksInfo);

    FreeAndNil(FSMTP);

    SetStatus('Concluído');
  end;
end;

function TEMail.GetError: string;
begin
  Result := Self.FError;
  SetStatus(Self.FStatus + ' ' + Result);
end;

function TEMail.GetStatus: string;
begin
  Result := FStatus;
end;

procedure TEMail.MontarImagensEmail(const AIdMessage: TIdMessage);
var
  FMensagem, FArquivo, FImagemID: String;
  FRegEx: TRegEx;
  FMatchCollection: TMatchCollection;
  FMatch: TMatch;
  FIdAttachmentFile: TIdAttachmentFile;
begin
  FMensagem := AIDMessage.Body.Text;

  FRegEx := TRegEx.Create('<img\s+src\s*=\s*(["''][^"'']+["'']|[^>]+)>', [roIgnoreCase, roMultiLine]);
  FMatchCollection := FRegEx.Matches(FMensagem);
  for FMatch in FMatchCollection do
  begin
    if not FMatch.success then
      Continue;

    FImagemID := FMatch.Groups[0].Value;
    FImagemID := FImagemID.Substring(FImagemID.IndexOf('cid:') + Length('cid:'), FImagemID.LastIndexOf('"') - (FImagemID.IndexOf('cid:') + Length('cid:')));

    FArquivo := FImagemID + '.jpg';
    if not FileExists(FArquivo) then
      Continue;

    FIdAttachmentFile := TIdAttachmentFile.Create(AIdMessage.MessageParts, FArquivo);
    FIdAttachmentFile.ContentType        := 'image/jpg';
    FIdAttachmentFile.ContentDisposition := 'inline';
    FIdAttachmentFile.ContentID          := '<' + FImagemID + '>';
  end;
end;

procedure TEMail.SetConfiguracoes(const Value: TConfiguracoes);
begin
  FConfiguracoes.Assign(Value);
end;

procedure TEMail.SetError(const AError: string);
begin
  FError := AError;

  if Assigned(FOnError) then
    OnError(AError);
end;

procedure TEMail.SetStatus(const AStatus: string);
begin
  Self.FStatus := AStatus;

  if Assigned(FOnStatus) then
    OnStatus(AStatus);
end;

function TConfiguracoes.GetUtilizaSSL: Boolean;
begin
  Result := False;

  if FUtilizaSSL then
    Exit(True);

  FUtilizaSSL := StrToIntDef(FPortaServidor, 0) > 300;
end;

end.
