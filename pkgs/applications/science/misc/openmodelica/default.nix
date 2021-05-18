{ buildPackages, pkgs, newScope, libsForQt5, stdenv }:
let
  callPackage = newScope ({
    mkOpenModelicaDerivation = callPackage ./mkderivation { };
  } // libsForQt5);
in
{
  omcompiler = callPackage ./omcompiler { };
  omplot = callPackage ./omplot { };
  omsimulator = callPackage ./omsimulator { };
  omparser = callPackage ./omparser { };
  omedit = callPackage ./omedit { };
  omlibrary = callPackage ./omlibrary { };
  omshell = callPackage ./omshell { };
  combined = callPackage ./combined { };
}
