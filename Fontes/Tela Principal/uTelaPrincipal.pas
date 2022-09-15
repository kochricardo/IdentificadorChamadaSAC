unit uTelaPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, AppEvnts, ExtCtrls, ActnList, PlatformDefaultStyleActnCtrls, ActnMan,
  ImgList, Menus, ActnPopup, ComCtrls, ScktComp, DBXOracle, DB, SqlExpr,
  StdCtrls, Buttons;

type
  T_frmPrincipal = class(TForm)
    _Iconizar: TTrayIcon;
    _Evento: TApplicationEvents;
    ActionManager1: TActionManager;
    ActSair: TAction;
    ActIniciarServidor: TAction;
    ActReiniciarServidor: TAction;
    ActPararServidor: TAction;
    ActSobre: TAction;
    ActMaximinizar: TAction;
    ActMinimizar: TAction;
    ActLogin: TAction;
    ActConfig: TAction;
    ImgServer: TImageList;
    ImageListLarge: TImageList;
    ImageListSmall: TImageList;
    PamServer: TPopupActionBar;
    Servidor2: TMenuItem;
    Iniciar1: TMenuItem;
    Parar1: TMenuItem;
    Reiniciar1: TMenuItem;
    N3: TMenuItem;
    maximinizar1: TMenuItem;
    Minimizar1: TMenuItem;
    FecharPrograma1: TMenuItem;
    StatusBar1: TStatusBar;
    Memo1: TMemo;
    conexaoBanco1: TSQLConnection;
    _identificador: TServerSocket;
    BitBtn1: TBitBtn;
    procedure ActMaximinizarExecute(Sender: TObject);
    procedure ActMinimizarExecute(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure _EventoMinimize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Servidor22ClientConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure Servidor22ClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure _identificadorClientConnect(Sender: TObject;
      Socket: TCustomWinSocket);
    procedure _identificadorClientRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure _IconizarDblClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    procedure HideServer;
    procedure ShowServer;
    procedure GravaLogLigacoes(nrTelefone, horaLigacao: String);
    procedure insertLogLigacaoSAC(dsTelefone: string);
    function VersaoExe: String;
    function TestaConexaoBase(Conectar: TSQLConnection; nrConexao: integer): Boolean;
    { Private declarations }
  public
    { Public declarations }
    iconizar : Boolean;
    dsVersao,
    nmBaseProducao,nmBaseT : String;

  end;

var
  _frmPrincipal: T_frmPrincipal;
  idConexoes :Tlist;
  pathPrograma:String;
  ContaLigacao:Integer;
  idip :String;



implementation

uses UtilConexao;

{$R *.dfm}

procedure T_frmPrincipal.ActMaximinizarExecute(Sender: TObject);
begin
 ShowServer;
end;

procedure T_frmPrincipal.ActMinimizarExecute(Sender: TObject);
begin
 HideServer;
end;

procedure T_frmPrincipal.BitBtn1Click(Sender: TObject);

begin
 //_identificador.Socket.Connections[0].SendText('Msg Recebida -->'+'Chamada recebida de: 5533136024');
// st :='Chamada recebida de: 5332221360';
//  st:= trim(copy(st,21,10));
//  nrTelefone:=st;

end;

procedure T_frmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 idConexoes.Free;
end;

procedure T_frmPrincipal.FormCreate(Sender: TObject);
begin
 pathPrograma:=ExtractFilePath(Application.ExeName);

   try
    if not TestaConexaoBase(conexaoBanco1,1) then
    begin
      nmBaseProducao:=nmBaseT;
      ShowMessage('Não conectado com Servidor RAC!!!');
      Application.Terminate;
      exit;
   end;
   nmBaseProducao:=nmBaseT;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message +' - '+'Erro conectar com servidor');
    end;
  end;


 _identificador.Active:=true;
 _identificador.Open;
 idConexoes:=TList.Create;
 idConexoes.Clear;
 if not DirectoryExists(pathPrograma+'ArquivoLigacoes') then
    ForceDirectories(pathPrograma+'ArquivoLigacoes');

 iconizar:=true;

 _frmPrincipal.WindowState:=wsMinimized;
 _frmPrincipal.Caption := _frmPrincipal.Caption+' Ver :'+VersaoExe;
end;

procedure T_frmPrincipal.FormDblClick(Sender: TObject);
begin
 ShowServer;
end;

procedure T_frmPrincipal.FormShow(Sender: TObject);
begin
 //HideServer;
end;

procedure T_frmPrincipal._EventoMinimize(Sender: TObject);
begin
 HideServer;
end;

procedure T_frmPrincipal._IconizarDblClick(Sender: TObject);
begin
 ShowServer;
end;

procedure T_frmPrincipal.HideServer;
begin
  _frmPrincipal.Hide;

  ActMaximinizar.Enabled      := True;
  ActMinimizar.Enabled        := False;
end;


procedure T_frmPrincipal._identificadorClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
var
  idSocket :^byte;
begin
 new(idSocket);
 Socket.Data:=idSocket;
 idConexoes.Add(Socket.Data);

 idip:=Socket.RemoteAddress;

end;

procedure T_frmPrincipal._identificadorClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
 var
  msgRecebida:String;
  idCli,
  nrTamanho :Integer;
  Horastr,nrTelefone:String;
  buffer       :  array[0..255] of Byte;
begin
  //nrTamanho:=Socket.ReceiveLength;
 if idip<>'10.1.1.23' then
 begin
    msgRecebida:=Socket.ReceiveText;
    Memo1.Lines.Add('Ip :'+idip+' Msg :'+msgRecebida+ ' Hr :' +FormatDateTime('HH:mm:ss',now)+' Data :' +FormatDateTime('dd/mm/yyyy',now));


 end;

 if idip='10.1.1.23' then
 begin
    msgRecebida:=Socket.ReceiveText;
    nrTelefone:=trim(copy(msgRecebida,21,13));
    Inc(ContaLigacao);
 if ContaLigacao>15 then
 begin
   Memo1.Clear;
   ContaLigacao:=0;
 end;
 memo1.Lines.Add(idip);
 Memo1.Lines.Add(msgRecebida);
 Memo1.Lines.Add('Nr. Telefone-->'+nrTelefone+' Hr :' +FormatDateTime('HH:mm:ss',now)+' Data :' +FormatDateTime('dd/mm/yyyy',now));
 GravaLogLigacoes(nrTelefone,FormatDateTime('HH:mm:ss',now));
 insertLogLigacaoSAC(nrTelefone);
 end;
 //_identificador.Socket.Connections[0].SendText('Msg Recebida -->'+msgRecebida);

end;

procedure T_frmPrincipal.Servidor22ClientConnect(Sender: TObject;
  Socket: TCustomWinSocket);
  var
  idSocket :^byte;
begin
 new(idSocket);
 Socket.Data:=idSocket;
 idConexoes.Add(Socket.Data);

end;

procedure T_frmPrincipal.Servidor22ClientRead(Sender: TObject;
  Socket: TCustomWinSocket);
 var
  msgRecebida:String;
  idCli,
  nrTamanho :Integer;
  Horastr,nrTelefone:String;
  buffer       :  array[0..255] of Byte;
begin
  //nrTamanho:=Socket.ReceiveLength;
 msgRecebida:=Socket.ReceiveText;
 nrTelefone:=trim(copy(msgRecebida,21,13));
 Memo1.Lines.Add(msgRecebida);
 nrTelefone:=trim(copy(msgRecebida,21,13));
 Memo1.Lines.Add('Nr. Telefone-->'+nrTelefone+' Hr :' +FormatDateTime('HH:mm:ss',now));
 GravaLogLigacoes(nrTelefone,FormatDateTime('HH:mm:ss',now));
 insertLogLigacaoSAC(nrTelefone);
 _identificador.Socket.Connections[0].SendText('Msg Recebida -->'+msgRecebida);
end;

procedure T_frmPrincipal.ShowServer;
begin
  _frmPrincipal.BringToFront;
  _frmPrincipal.Show;
  _frmPrincipal.WindowState := wsNormal;
  _frmPrincipal.SetFocus;


  ActMaximinizar.Enabled := False;
  ActMinimizar.Enabled   := True;
end;

procedure T_frmPrincipal.GravaLogLigacoes(nrTelefone,horaLigacao:String);
var
 arquivoTexto:TextFile;
 textoLinha:String;
begin
   textoLinha:= ' Data Ligacao :'+FormatDateTime('dd/mm/yyyy',now) +
                ' Hora Ligacao :'+horaLigacao+
                ' Nr. Telefone : '+nrTelefone;
   AssignFile(arquivoTexto,pathPrograma+'ArquivoLigacoes\LigacoesSAC.TXT');
   if not FileExists(pathPrograma+'ArquivoLigacoes\LigacoesSAC.TXT') then
   begin
      Rewrite(arquivoTexto);
   end
   else
   begin
      Append(arquivoTexto);
   end;
  try
   Writeln(arquivoTexto,textoLinha);
  finally
  CloseFile(arquivoTexto);
  end
end;



procedure T_frmPrincipal.insertLogLigacaoSAC(dsTelefone:string);
  function getIDLigacao: integer;
  var
    sqlData : TSQLQuery;
  begin
    sqlData:=TSQLQuery.Create(nil);
    sqlData.SQLConnection:=conexaoBanco1;
    try
      try
        sqlData.Close;
        sqlData.sql.Add('SELECT MAX(CD_LOG_LIGACAO) MAX '+
                                      'FROM PRDDM.DC_SAC_LOG_LIGACAO');
        sqlData.Open;
        Result:=sqlData.FieldByName('MAX').AsInteger + 1;
      except
        on E:Exception do
          raise Exception.Create(E.Message);
      end;
    finally
      sqlData.Close;
      sqlData.Free;
    end;
  end;
var
  sqlTxt : string;
  sqlQuery : TSQLQuery;
  i: integer;
begin
  sqlQuery:=TSQLQuery.Create(nil);
  sqlQuery.SQLConnection:=conexaoBanco1;
  try
    try
      sqlTxt:='INSERT INTO PRDDM.DC_SAC_LOG_LIGACAO (CD_LOG_LIGACAO, NR_TELEFONE,';
      sqlTxt:=sqlTxt + 'DT_LIGACAO,CD_TIPO_ATENDIMENTO,NM_USUARIO,';
      sqlTxt:=sqlTxt + 'CD_OCORRENCIA,DT_ATUALIZACAO ) VALUES (';
      sqlTxt:=sqlTxt + inttostr(getIDLigacao)+',';
      sqlTxt:=sqlTxt + QuotedStr(copy(TRIM(dsTelefone),1,10))+',';
      sqlTxt:=sqlTxt + 'SYSDATE'+',';
      sqlTxt:=sqlTxt + QuotedStr('1')+',';
      sqlTxt:=sqlTxt + QuotedStr('SAC')+',';
      sqlTxt:=sqlTxt + QuotedStr('0')+',';
      sqlTxt:=sqlTxt + 'SYSDATE';
      sqlTxt:=sqlTxt + ')';
      sqlQuery.Close;
      sqlQuery.SQL.Text:=sqlTxt;
      sqlQuery.ExecSQL;
    except
      on E:Exception do
        raise Exception.Create(E.Message);
    end;
  finally
    sqlQuery.Free;
    sqlQuery:=nil;
  end;
end;

{$REGION 'Pegar a Versão do Sistema'}
Function T_frmPrincipal.VersaoExe: String;
type
PFFI = ^vs_FixedFileInfo;
var
F : PFFI;
Handle : Dword;
Len : Longint;
Data : Pchar;
Buffer : Pointer;
Tamanho : Dword;
Parquivo: Pchar;
Arquivo : String;
begin
Arquivo := Application.ExeName;
Parquivo := StrAlloc(Length(Arquivo) + 1);
StrPcopy(Parquivo, Arquivo);
Len := GetFileVersionInfoSize(Parquivo, Handle);
Result := '';
if Len > 0 then
begin
Data:=StrAlloc(Len+1);
if GetFileVersionInfo(Parquivo,Handle,Len,Data) then
begin
VerQueryValue(Data, '\',Buffer,Tamanho);
F := PFFI(Buffer);
Result := Format('%d.%d.%d.%d',
[HiWord(F^.dwFileVersionMs),
LoWord(F^.dwFileVersionMs),
HiWord(F^.dwFileVersionLs),
Loword(F^.dwFileVersionLs)]
);
end;
StrDispose(Data);
end;
StrDispose(Parquivo);
end;
{$ENDREGION}


function T_frmPrincipal.TestaConexaoBase(Conectar: TSQLConnection; nrConexao: integer):Boolean;
begin
  Try
    Result := FALSE;
    Conectar.connected := false;
    Conectar.Params.Clear;
    Conectar.Params.LoadFromFile(loadConexao(nrConexao));
    Conectar.connected := true;
    //nmBaseT := UpperCase(Conectar.Params.Values['database']);
    Result := true;
  except
    begin
      Result := false;
    end;
  end;

end;



end.
