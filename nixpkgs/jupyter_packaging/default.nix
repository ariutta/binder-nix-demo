{ stdenv, python3 }:

let
  inherit (python3.pkgs) buildPythonPackage fetchPypi;
in

buildPythonPackage rec {
  pname = "jupyter_packaging";
  version = "0.7.11";
  name = "${pname}-${version}";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0ma4dsi2rjha1d592wkranbz4ppzwpvakgmybxzx3bqgdpi6w9gh";
  };

  buildInputs = with python3.pkgs; [
    packaging
  ];

  meta = with stdenv.lib; {
    description = "Tools to help build and install Jupyter Python packages.";
    homepage = "https://github.com/jupyter/jupyter-packaging";
    license = licenses.bsd3;
    maintainers = with maintainers; [ ];
  };
}
