_: pkgs:
let
  jupyter_packaging = pkgs.python3Packages.callPackage ./nixpkgs/jupyter_packaging/default.nix {};
  json5 = pkgs.python3Packages.callPackage ./nixpkgs/json5/default.nix {};
  jupyter_server = pkgs.python3Packages.callPackage ./nixpkgs/jupyter_server/default.nix {
    nbconvert=pkgs.python3.pkgs.nbconvert;
  };
  jupyterlab_server = pkgs.python3Packages.callPackage ./nixpkgs/jupyterlab_server/default.nix {
    json5=json5;
    jupyter_server=jupyter_server;
  };
  nbclassic = pkgs.python3Packages.callPackage ./nixpkgs/nbclassic/default.nix {
    jupyter_packaging=jupyter_packaging;
    jupyter_server=jupyter_server;
    notebook=pkgs.python3.pkgs.notebook;
  };
  packageOverrides = selfPythonPackages: pythonPackages: {
    json5=json5;
    nbclassic = nbclassic;
    jupyter_packaging = jupyter_packaging;
    jupyter_server=jupyter_server;
    jupyterlab_server = jupyterlab_server;
    jupyterlab = selfPythonPackages.callPackage ./nixpkgs/jupyterlab/default.nix {
      jupyter_packaging=jupyter_packaging;
      jupyterlab_server=jupyterlab_server;
      jupyter_server=jupyter_server;
      nbclassic=nbclassic;
    };
    nb_black = selfPythonPackages.callPackage ./nixpkgs/nb_black/default.nix {};
    seaborn = selfPythonPackages.callPackage ./nixpkgs/seaborn/default.nix {};
    skosmos_client = selfPythonPackages.callPackage ./nixpkgs/skosmos_client/default.nix {};
    wikidata2df = selfPythonPackages.callPackage ./nixpkgs/wikidata2df/default.nix {};
    homoglyphs = selfPythonPackages.callPackage ./nixpkgs/homoglyphs/default.nix {};
    confusable-homoglyphs = selfPythonPackages.callPackage ./nixpkgs/confusable-homoglyphs/default.nix {};
    pyahocorasick = selfPythonPackages.callPackage ./nixpkgs/pyahocorasick/default.nix {};
  };

in

{
  python3 = pkgs.python3.override (old: {
    packageOverrides =
      pkgs.lib.composeExtensions
        (old.packageOverrides or (_: _: {}))
        packageOverrides;
  });
}
