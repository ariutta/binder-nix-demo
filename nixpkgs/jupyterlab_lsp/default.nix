{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, jupyterlab
, jupyter_lsp
, python3Packages
, python3
, R
, rPackages
}:

buildPythonPackage rec {
  pname = "jupyterlab-lsp";
  version = "3.3.0";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "10c2cdkc85pxi24v3i9k19krbn9s8b7qvsv8dqy9fr8jmf03yj80";
  };

  doCheck = true;
  buildInputs = [ setuptools ];
  propagatedBuildInputs = [ jupyterlab jupyter_lsp python3 R python3Packages.python-language-server python3Packages.rope rPackages.languageserver ];

  meta = with lib; {
    description = "Language Server Protocol integration for JupyterLab.";
    homepage = "https://pypi.org/project/jupyterlab-lsp/";
    license = licenses.bsd3;
    maintainers = [];
  };
}
