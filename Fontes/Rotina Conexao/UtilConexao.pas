unit UtilConexao;

interface

uses IniFiles,SysUtils,Forms;

function loadConexao(nrConexao:Integer):String;

implementation

function loadConexao(nrConexao:Integer):String;
var
 ArqIni:TIniFile;
begin
  try
    ArqIni := TIniFile.Create(ExtractFilePath(Application.ExeName)+'Config.ini');
    Result:=ArqIni.ReadString('Conexao', 'dsConexao'+inttostr(nrConexao),'');
    Result:='C:\GAM\Sistemas\Configuracoes\'+Result+'.ini';
    ArqIni.Free;
  except
    Result:='';
  end;
end;

end.
