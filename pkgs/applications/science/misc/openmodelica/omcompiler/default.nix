{stdenv, lib, mkOpenModelicaDerivation, autoconf, automake, libtool,
gfortran, clang, cmake, curl, hwloc, jre, openblas, hdf5, expat, ncurses,
readline, which, lp_solve, omniorb, sqlite, libatomic_ops,
pkgconfig, file, gettext, flex, bison, doxygen, boost,
ipopt, libuuid, git, makeWrapper, autoreconfHook}:

mkOpenModelicaDerivation rec {
  pname = "omcompiler";
  omtarget = "omc";
  omdeps = [];

  nativeBuildInputs = [autoconf automake libtool cmake gfortran clang makeWrapper
    flex bison doxygen
    pkgconfig file
    autoreconfHook];

  buildInputs = [hwloc curl
    jre openblas hdf5 expat ncurses readline which lp_solve
    omniorb sqlite libatomic_ops gettext boost
    ipopt libuuid
    git makeWrapper];

#    sed 3rdParty/Ipopt/configure -e 's|for dir in $abs_lib_dir|for dir in -z,origin|'
#    sed -i ''$(find -name CMakeLists.txt) -e 's|/''${CMAKE_LIBRARY_ARCHITECTURE}||'
#    sed -i ''$(find -name Makefile.in) -e 's|/@host_short@||'

  preFixup = ''
    for entry in $(find $out -name libipopt.so); do
      patchelf --shrink-rpath --allowed-rpath-prefixes /nix/store $entry
      patchelf --set-rpath '$ORIGIN':"$(patchelf --print-rpath $entry)" $entry
    done
  '';
}
