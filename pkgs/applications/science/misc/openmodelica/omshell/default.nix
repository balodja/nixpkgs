{lib, qttools, qmake, qtwebkit, wrapQtAppsHook, readline, openmodelica, mkOpenModelicaDerivation}:

with openmodelica;
mkOpenModelicaDerivation rec {
  pname = "omshell";
  omdir = "OMShell";
  omdeps = [omcompiler];
  omautoconf = true;

  nativeBuildInputs = [qmake wrapQtAppsHook];

  buildInputs = [readline qtwebkit];

  postPatch = ''
    sed -i ''$(find -name qmake.m4) -e '/^\s*LRELEASE=/ s|LRELEASE=.*$|LRELEASE=${lib.getDev qttools}/bin/lrelease|'
    sed -i OMShell/OMShell/OMShellGUI/*.pro -e '
      s|\$\$\[QT_INSTALL_BINS\]/lrelease|${lib.getDev qttools}/bin/lrelease|
      /^\s*OMCLIBS =/ s|\$\$(OMBUILDDIR)|${omcompiler}|
      /^\s*OMCINC =/ s|\$\$(OMBUILDDIR)|${omcompiler}|
    '
    sed -i OMShell/OMShell/OMShellGUI/OMShell.config.in -e '
      s|@OMBUILDDIR@|${omcompiler}|
      s|@OPENMODELICAHOME@|${omcompiler}|
    '
    sed -i OMShell/mosh/src/Makefile.in -e '
      /^CFLAGS =/ s|-I../../../build|-I${omcompiler}|
      /^LIBS =/ s|-L@OMBUILDDIR@|-L${omcompiler}|
      '
    '';

  dontUseQmakeConfigure = true;
}
