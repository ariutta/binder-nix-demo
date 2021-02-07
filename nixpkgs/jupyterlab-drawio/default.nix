{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, jupyterlab
}:

buildPythonPackage rec {
  pname = "jupyterlab-drawio";
  version = "0.8.0";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "02c056nlvnap8fz52ksjyqm933rlqwa2zzv2a3v2b70cs224gidg";
  };

  doCheck = true;
  buildInputs = [ setuptools ];
  propagatedBuildInputs = [ jupyterlab ];

#  format = "other";
#
#  buildPhase = ''
#    mkdir -p "$out/lib/python3.8/site-packages"
#    cp -r ./jupyterlab-drawio "$out/lib/python3.8/site-packages/jupyterlab-drawio"
#
#    mkdir -p "$out/share/jupyter/labextensions"
#    cp -r ./jupyterlab-drawio/labextension "$out/share/jupyter/labextensions/jupyterlab-drawio"
#    cp ./install.json "$out/share/jupyter/labextensions/jupyterlab-drawio/install.json"
#  '';
#
#  installPhase = ''
#    echo "installPhase" 1>&2
#  '';

  meta = with lib; {
    description = "A JupyterLab extension for embedding drawio / mxgraph.";
    homepage = "https://pypi.org/project/jupyterlab-drawio/";
    license = licenses.bsd3;
    maintainers = [];
  };
}
