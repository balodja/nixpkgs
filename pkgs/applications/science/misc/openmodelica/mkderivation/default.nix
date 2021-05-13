# mkOpenModelicaDerivation is an mkDerivation function for packages
# from OpenModelica suite.

{stdenv, lib, fetchgit, autoconf, automake, libtool, cmake, autoreconfHook, symlinkJoin}:
pkg:

let
  inherit (builtins) hasAttr getAttr length elemAt;
  inherit (lib) attrByPath concatStringsSep;


  # A few helpers functions:

  # getAttrDef is just a getAttr with default fallback
  getAttrDef = attr: default: x: attrByPath [attr] default x;

  # getAttr-like helper for optional append to string:
  # "Hello" + appendByAttr "a" " " {a = "world";} = "Hello world"
  # "Hello" + appendByAttr "a" " " {} = "Hello"
  appendByAttr = attr: sep: x: if hasAttr attr x then sep + (getAttr attr x) else "";

  # Partially applied "if"
  ifNoDeps = def: x:
    if length pkg.omdeps == 0 then def else x;


  # Dependencies of current OpenModelica-target joined in one file tree.
  # Return the dep itself in case it is a single one.
  joinedDeps =
    if length pkg.omdeps == 1
    then elemAt pkg.omdeps 0
    else symlinkJoin {
           name = pkg.pname + "-omhome";
           paths = pkg.omdeps;
         };

  # Should we run ./configure for the target pkg?
  omautoconf = getAttrDef "omautoconf" false pkg;

  # Name of the make target
  omtarget = getAttrDef "omtarget" pkg.pname pkg;

  # Directory of target sources
  omdir = getAttrDef "omdir" pkg.pname pkg;

  # Simple to to m4 configuration scripts
  postPatch = ifNoDeps "" ''
      sed -i ''$(find -name omhome.m4) -e 's|if test ! -z "$USINGPRESETBUILDDIR"|if test ! -z "$USINGPRESETBUILDDIR" -a -z "$OMHOME"|'
    '' +
    appendByAttr "postPatch" "\n" pkg;

  # Update shebangs in the scripts before running configuration.
  preAutoreconf = "patchShebangs --build common" +
    appendByAttr "preAutoreconf" "\n" pkg;

  # Tell OpenModelica where built dependencies are located.
  configureFlags = ifNoDeps "" "--with-openmodelicahome=${joinedDeps}" +
    appendByAttr "configureFlags" " " pkg;

  # Our own configurePhase that accounts for omautoconf
  configurePhase = ''
    runHook preConfigure
    export configureFlags="''${configureFlags} --with-ombuilddir=$PWD/build --prefix=$prefix"
    ./configure --no-recursion $configureFlags;
    if ${if omautoconf then "true" else "false"}; then
      (cd ${omdir}; ./configure $configureFlags);
    fi
    runHook postConfigure
    '';

  # Targets that we want to build ourselves:
  deptargets = lib.forEach pkg.omdeps (dep: dep.omtarget);

  # ... so we ask openmodelica makefile to skip those targets.
  preBuild = ''
    for target in ${concatStringsSep " " deptargets}; do
      touch ''${target}.skip;
    done
    '' +
    appendByAttr "preBuild" "\n" pkg;

  makeFlags = "${omtarget}" +
    appendByAttr "makeFlags" " " pkg;

  installFlags = "-i " +
    appendByAttr "installFlags" " " pkg;


in stdenv.mkDerivation (pkg // {
  inherit omtarget;
  inherit postPatch;
  inherit preAutoreconf;
  inherit configureFlags configurePhase;
  inherit preBuild;
  inherit makeFlags installFlags;

  src = fetchgit (import ./src-main.nix);
  version = "1.17.0";

  nativeBuildInputs = pkg.nativeBuildInputs ++
    [autoconf automake libtool cmake autoreconfHook];

  buildInputs = pkg.buildInputs ++ [joinedDeps];

  dontUseCmakeConfigure = true;

  hardeningDisable = ["format"];

  meta = with lib; {
    description = "An open-source Modelica-based modeling and simulation environment";
    homepage    = "https://openmodelica.org";
    license     = licenses.gpl3Only;
    maintainers = with maintainers; [ smironov ];
    platforms   = platforms.linux;
  };
})
