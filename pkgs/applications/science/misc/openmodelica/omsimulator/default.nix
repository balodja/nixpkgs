{pkg-config, readline, libxml2,
openmodelica, mkOpenModelicaDerivation}:

mkOpenModelicaDerivation rec {
  pname = "omsimulator";
  omdir = "OMSimulator";
  omdeps = [openmodelica.omcompiler];

  nativeBuildInputs = [pkg-config];

  buildInputs = [readline libxml2];
}
