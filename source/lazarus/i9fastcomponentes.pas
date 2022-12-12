{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit i9fastcomponentes;

{$warn 5023 off : no warning about unused units}
interface

uses
  email, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('email', @email.Register);
end;

initialization
  RegisterPackage('i9fastcomponentes', @Register);
end.
