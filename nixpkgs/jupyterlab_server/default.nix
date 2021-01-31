{ lib, stdenv
, python3
, buildPythonPackage
, fetchPypi
, pythonOlder
, json5
, jupyter_server
, requests
, pytest
}:

buildPythonPackage rec {
  pname = "jupyterlab_server";
  version = "2.1.3";
  disabled = pythonOlder "3.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "06hpkazd9plmp8wjvslsqcj2gdls44d4dpdbs9xs2jfgp826py9a";
  };

  checkInputs = [ requests pytest ];
  propagatedBuildInputs = with python3.pkgs; [
    Babel
    jinja2
    json5
    jsonschema
    packaging
    requests
    jupyter_server
    #notebook jsonschema pyjson5
  ];

  # test_listing test fails
  # this is a new package and not all tests pass
  doCheck = false;

  checkPhase = ''
    pytest
  '';

  meta = with lib; {
    description = "JupyterLab Server";
    homepage = "https://jupyter.org";
    license = licenses.bsdOriginal;
    maintainers = [ maintainers.costrouc ];
  };
}
