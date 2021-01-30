with import <nixpkgs> {};
let
  pythonEnv = python38.withPackages (ps: [
    ps.numpy
    ps.toolz
    ps.numpy
    ps.scipy
    ps.jupyterlab
  ]);
in mkShell {
  buildInputs = [
    pythonEnv

    black
    mypy

    libffi
    openssl
  ];
}
