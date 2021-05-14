{stdenv, gfortran, flex, bison, jre8, blas, lapack, curl, readline, expat, pkg-config,
targetPackages,
libffi, binutils, mkOpenModelicaDerivation}:

mkOpenModelicaDerivation rec {
  pname = "omcompiler";
  omtarget = "omc";
  omdir = "OMCompiler";
  omdeps = [];
  omautoconf = true;

  nativeBuildInputs = [jre8 gfortran flex bison pkg-config];

  buildInputs = [targetPackages.stdenv.cc.cc blas lapack curl readline expat libffi binutils];

  postPatch = ''
    sed -i -e '/^\s*AR=ar$/ s/ar/${stdenv.cc.targetPrefix}ar/
               /^\s*ar / s/ar /${stdenv.cc.targetPrefix}ar /
               /^\s*ranlib/ s/ranlib /${stdenv.cc.targetPrefix}ranlib /' \
        $(find ./OMCompiler -name 'Makefile*')
  '';

  preFixup = ''
    for entry in $(find $out -name libipopt.so); do
      patchelf --shrink-rpath --allowed-rpath-prefixes /nix/store $entry
      patchelf --set-rpath '$ORIGIN':"$(patchelf --print-rpath $entry)" $entry
    done
  '';
}
