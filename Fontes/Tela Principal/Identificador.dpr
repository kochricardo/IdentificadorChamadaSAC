program Identificador;

uses
  Forms,
  uTelaPrincipal in 'uTelaPrincipal.pas' {_frmPrincipal},
  UtilConexao in '..\Rotina Conexao\UtilConexao.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Indentificador SAC';
  Application.CreateForm(T_frmPrincipal, _frmPrincipal);
  Application.Run;
end.
