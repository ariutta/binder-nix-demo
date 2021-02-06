_: pkgs:
let
  jupyter_packaging = pkgs.python3Packages.callPackage ./nixpkgs/jupyter_packaging/default.nix {};
  json5 = pkgs.python3Packages.callPackage ./nixpkgs/json5/default.nix {};
  jupyter_server = pkgs.python3Packages.callPackage ./nixpkgs/jupyter_server/default.nix {};
  jupyterlab_server = pkgs.python3Packages.callPackage ./nixpkgs/jupyterlab_server/default.nix {
    inherit json5 jupyter_server;
  };
  nbclassic = pkgs.python3Packages.callPackage ./nixpkgs/nbclassic/default.nix {
    inherit jupyter_packaging jupyter_server;
  };
  jupyterlab = pkgs.python3Packages.callPackage ./nixpkgs/jupyterlab/default.nix {
    inherit nbclassic jupyter_packaging jupyter_server jupyterlab_server;
  };
  jupyter_lsp = pkgs.python3Packages.callPackage ./nixpkgs/jupyter_lsp/default.nix {
    inherit nbclassic jupyter_packaging jupyter_server jupyterlab_server;
  };
  packageOverrides = selfPythonPackages: pythonPackages: {
    inherit json5 nbclassic jupyter_packaging jupyter_server jupyterlab_server jupyterlab jupyter_lsp;
    jupyterlab-lsp = selfPythonPackages.callPackage ./nixpkgs/jupyterlab_lsp/default.nix {
      inherit jupyterlab jupyter_lsp;
    };
    jupyterlab_code_formatter = selfPythonPackages.callPackage ./nixpkgs/jupyterlab_code_formatter/default.nix {
      inherit jupyterlab;
    };
    jupyterlab_hide_code = selfPythonPackages.callPackage ./nixpkgs/jupyterlab_hide_code/default.nix {
      inherit jupyterlab;
    };
    jupyterlab_vim = selfPythonPackages.callPackage ./nixpkgs/jupyterlab_vim/default.nix {
      inherit jupyterlab jupyter_packaging;
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
