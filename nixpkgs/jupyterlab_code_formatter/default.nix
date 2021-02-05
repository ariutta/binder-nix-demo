{ lib
, buildPythonPackage
, fetchPypi
, jupyterlab
}:

buildPythonPackage rec {
  pname = "jupyterlab_code_formatter";
  version = "1.4.3";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "089l6hy7dzflbx8dk9r8wfxf5azd8w8az57ij3lhi4j2dcl9l2bg";
  };

  doCheck = true;
  buildInputs = [];
  # should isort and black be included here?
  propagatedBuildInputs = [ jupyterlab ];

  meta = with lib; {
    description = "Code formatter for JupyterLab.";
    homepage = "https://pypi.org/project/jupyterlab-code-formatter/";
    license = licenses.mit;
    maintainers = [];
  };
}
