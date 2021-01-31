{ stdenv, python3 }:

let
  inherit (python3.pkgs) buildPythonPackage fetchPypi;
in

buildPythonPackage rec {
  pname = "json5";
  version = "0.9.5";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "15nvdg8a8al1hfnqwdfwf64xkc64lsmcdqcjdaspc1br83jzwg3h";
  };

  propagatedBuildInputs = with python3.pkgs; [];

  doCheck = false;

  meta = with stdenv.lib; {
    description = "Format Python in Jupyter with Black.";
    longDescription = ''
      A simple extension for Jupyter Notebook and Jupyter Lab to beautify Python
      code automatically using black.
      '';
    homepage = "https://pypi.org/project/nb_black/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
