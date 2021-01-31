let
  # Path to the JupyterWith folder.
  jupyterWithPath = builtins.fetchGit {
    url = https://github.com/tweag/jupyterWith;
    rev = "35eb565c6d00f3c61ef5e74e7e41870cfa3926f7";
  };

  mynixpkgs = import (builtins.fetchGit {
    url = https://github.com/ariutta/mynixpkgs;
    rev = "f2971b217022189a7ca9a77f82211fa345100524";
  });

  # Importing overlays from that path.
  overlays = [
    # Only necessary for Haskell kernel
    (import "${jupyterWithPath}/nix/haskell-overlay.nix")
    # Necessary for Jupyter
    (import "${jupyterWithPath}/nix/python-overlay.nix")
    (import "${jupyterWithPath}/nix/overlay.nix")
    # plus my custom python overlays
    (import ./python-overlay.nix)
  ];

  # Your Nixpkgs snapshot, with JupyterWith packages.
  pkgs = import <nixpkgs> { inherit overlays; };

  # From here, everything happens as in other examples.
  jupyter = pkgs.jupyterWith;

  #########################
  # R
  #########################

  myRPackages = p: with p; [
    pacman
    dplyr
    ggplot2
    knitr
    purrr
    readr
    stringr
    tidyr
  ];

  myR = [ pkgs.R ] ++ (myRPackages pkgs.rPackages);

  irkernel = jupyter.kernels.iRWith {
    # Identifier that will appear on the Jupyter interface.
    name = "irkernel";
    # Libraries to be available to the kernel.
    packages = myRPackages;
    # Optional definition of `rPackages` to be used.
    # Useful for overlaying packages.
    rPackages = pkgs.rPackages;
  };

#  # juniper doesn't work anymore, it appears
#  juniper = jupyter.kernels.juniperWith {
#    # Identifier that will appear on the Jupyter interface.
#    name = "JuniperKernel";
#    # Libraries (R packages) to be available to the kernel.
#    packages = myRPackages;
#    # Optional definition of `rPackages` to be used.
#    # Useful for overlaying packages.
#    # TODO: why not just do this in overlays above?
#    #rPackages = pkgs.rPackages;
#  };

  #########################
  # Python
  #########################

  iPython = jupyter.kernels.iPythonWith {
    name = "iPython";
    packages = p: with p; [
      numpy
      pandas

      # TODO: the following are not serverextensions, but they ARE specifically
      # intended for augmenting jupyter. Where should we specify them?

      # TODO: compare nb_black with https://github.com/ryantam626/jupyterlab_code_formatter
      nb_black

      beautifulsoup4
      soupsieve

      nbconvert
      seaborn

      requests
      requests-cache

      #google_api_core
      #google_cloud_core
      #google-cloud-sdk
      #google_cloud_testutils
      #google_cloud_automl
      #google_cloud_storage

      # tzlocal is needed to make rpy2 work
      tzlocal
      rpy2

      pyahocorasick
      spacy

      unidecode
      homoglyphs
      confusable-homoglyphs

      # Python interface to the libmagic file type identification library
      python_magic
      # python bindings for imagemagick
      Wand
      # Python Imaging Library
      pillow

      # fix encodings
      ftfy

      lxml
      wikidata2df
      skosmos_client
    ];
  };

  jupyterEnvironment =
    jupyter.jupyterlabWith {
      kernels = [ iPython irkernel ];
      extraPackages = p: [
        # needed by jupyterlab-launch
        p.ps
        p.lsof

        # optionals below

        p.imagemagick

        # TODO: do we still need these for lab extensions?
        p.nodejs
        p.yarn

        # for nbconvert
        p.pandoc
        # see https://github.com/jupyter/nbconvert/issues/808
        #tectonic
        # more info: https://nixos.wiki/wiki/TexLive
        p.texlive.combined.scheme-full
        mynixpkgs.jupyterlab-connect

        # to run AutoML Vision
        p.google-cloud-sdk

        p.exiftool

        # to get perceptual hash values of images
        # p.phash
        p.blockhash
      ];

      extraJupyterPath = pkgs:
        "${pkgs.python3Packages.jupytext}/lib/python3.8/site-packages";
    };
in
  #jupyterEnvironment.env
  jupyterEnvironment.env.overrideAttrs (oldAttrs: {
    shellHook = oldAttrs.shellHook + ''
    . "${mynixpkgs.jupyterlab-connect}"/share/bash-completion/completions/jupyterlab-connect.bash
    '';
  })
