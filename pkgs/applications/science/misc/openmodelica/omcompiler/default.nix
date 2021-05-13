{gfortran, flex, bison, jre8, blas, lapack, curl, readline, expat, pkg-config,
libffi, binutils, mkOpenModelicaDerivation}:

mkOpenModelicaDerivation rec {
  pname = "omcompiler";
  omtarget = "omc";
  omdir = "OMCompiler";
  omdeps = [];
  omautoconf = true;

  nativeBuildInputs = [jre8 gfortran flex bison pkg-config];

  buildInputs = [blas lapack curl readline expat libffi binutils];

  preFixup = ''
    for entry in $(find $out -name libipopt.so); do
      patchelf --shrink-rpath --allowed-rpath-prefixes /nix/store $entry
      patchelf --set-rpath '$ORIGIN':"$(patchelf --print-rpath $entry)" $entry
    done
  '';
}
