{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, jupyter_server
#, nbclassic
#, jupyter_packaging
#, jupyterlab_server
, pytest
, pytestrunner
}:

buildPythonPackage rec {
  pname = "jupyter-lsp";
  version = "1.1.2";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0g8vf71i9xfnbz2j83i3bddxvh7q8sk85p4r5r3kjlmrjh76gpni";
  };

  buildInputs = [ setuptools ];
  #propagatedBuildInputs = [ nbclassic jupyter_packaging jupyter_server jupyterlab_server ];
  propagatedBuildInputs = [ jupyter_server ];
  doCheck = true;
  checkInputs = [ pytest pytestrunner ];

  meta = with lib; {
    description = "Multi-Language Server WebSocket proxy for Jupyter Notebook/Lab server.";
    homepage = "https://pypi.org/project/jupyter-lsp/";
    license = licenses.bsd3;
    maintainers = [];
  };
}
