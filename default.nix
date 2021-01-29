with import <nixpkgs> {};
with pkgs.lib.strings;
let
  # This property is just for jupyter server extensions, but it is
  # OK if the server extension includes a lab extension.
  serverextensions = p: with p; [
    jupytext
    # look into getting jupyterlab-lsp working:
    # https://github.com/krassowski/jupyterlab-lsp
  ];

  mynixpkgs = import (fetchFromGitHub {
    owner = "ariutta";
    repo = "mynixpkgs";
    rev = "aca57c0";
    sha256 = "1ab3izpdfiylzdxq1hpgljbcmdvdwnch8mxcd6ybx4yz8hlp8gm0";
  });

  # TODO: specify a lab extensions property

  jupyter = import (

#    # for dev, clone a jupyterWith fork as a sibling of demo directory
#    ../jupyterWith/default.nix

    # for "prod"
    builtins.fetchGit {
      url = https://github.com/ariutta/jupyterWith;
      ref = "proposals";
    }

  ) {
    # this corresponds to notebook_dir (impure)
    directory = toString ./.;
    labextensions = [
      "jupyterlab_vim"

      # TODO: this may have been needed for bokeh. Can I remove it?
      "@jupyter-widgets/jupyterlab-manager"

    ];
    serverextensions = serverextensions;
    overlays = [ (import ./python-overlay.nix) ];
  };

  #########################
  # Python
  #########################

  myPythonPackages = (p: (with p; [
    numpy
    pandas
  ]) ++
  # TODO: it would be nice not have to specify serverextensions here, but the
  # current jupyterLab code needs it to be specified both here and above.
  (serverextensions p));

  myPython = pkgs.python3.withPackages(myPythonPackages);

  iPythonWithPackages = jupyter.kernels.iPythonWith {
    name = "IPythonKernel";

    # TODO: I shouldn't need to set this if I'm using overlays, right?
    #python3 = pkgs.python3Packages;

    packages = myPythonPackages;
  };

  jupyterEnvironment =
    jupyter.jupyterlabWith {
      kernels = [ iPythonWithPackages ];

      extraPackages = p: [
        # needed by jupyterlab-launch
        p.ps
        p.lsof
        p.re2

        # needed to make server extensions work
        myPython

        # TODO: do we still need these for lab extensions?
        nodejs
        yarn

        # for nbconvert
        pandoc
        # see https://github.com/jupyter/nbconvert/issues/808
        #tectonic
        # more info: https://nixos.wiki/wiki/TexLive
        texlive.combined.scheme-full
        mynixpkgs.jupyterlab-connect

      ];
    };
in
  jupyterEnvironment.env.overrideAttrs (oldAttrs: {
    shellHook = oldAttrs.shellHook + ''
    . "${mynixpkgs.jupyterlab-connect}"/share/bash-completion/completions/jupyterlab-connect.bash
    '';
  })
