let
  rootDirectoryImpure = ".";
  shareDirectoryImpure = "${rootDirectoryImpure}/share-jupyter";
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
    # my custom python overlays
    (import ./python-overlay.nix)
    # jupyterWith overlays
    # Only necessary for Haskell kernel
    (import "${jupyterWithPath}/nix/haskell-overlay.nix")
    # Necessary for Jupyter
    (import "${jupyterWithPath}/nix/python-overlay.nix")
    (import "${jupyterWithPath}/nix/overlay.nix")
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

      # some of these may be needed to make rpy2 work
      simplegeneric
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
      directory = shareDirectoryImpure;
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
  jupyterEnvironment.env.overrideAttrs (oldAttrs: {
    shellHook = oldAttrs.shellHook + ''
    . "${mynixpkgs.jupyterlab-connect}"/share/bash-completion/completions/jupyterlab-connect.bash
    # this is needed in order that tools like curl and git can work with SSL
    if [ ! -f "$SSL_CERT_FILE" ] || [ ! -f "$NIX_SSL_CERT_FILE" ]; then
      candidate_ssl_cert_file=""
      if [ -f "$SSL_CERT_FILE" ]; then
        candidate_ssl_cert_file="$SSL_CERT_FILE"
      elif [ -f "$NIX_SSL_CERT_FILE" ]; then
        candidate_ssl_cert_file="$NIX_SSL_CERT_FILE"
      else
        candidate_ssl_cert_file="/etc/ssl/certs/ca-bundle.crt"
      fi
      if [ -f "$candidate_ssl_cert_file" ]; then
          export SSL_CERT_FILE="$candidate_ssl_cert_file"
          export NIX_SSL_CERT_FILE="$candidate_ssl_cert_file"
      else
        echo "Cannot find a valid SSL certificate file. curl will not work." 1>&2
      fi
    fi
    #export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

    # set SOURCE_DATE_EPOCH so that we can use python wheels
    SOURCE_DATE_EPOCH=$(date +%s)

    export JUPYTER_CONFIG_DIR="${shareDirectoryImpure}/config"
    export JUPYTER_DATA_DIR="${shareDirectoryImpure}/data"
    export JUPYTER_RUNTIME_DIR="${shareDirectoryImpure}/runtime"
    export JUPYTERLAB_DIR="${shareDirectoryImpure}/lab"

    if [ ! -d "${shareDirectoryImpure}" ]; then
      mkdir -p "$JUPYTER_CONFIG_DIR"
      mkdir -p "$JUPYTER_DATA_DIR"
      mkdir -p "$JUPYTER_RUNTIME_DIR"
      mkdir -p "$JUPYTERLAB_DIR"/extensions
      # We need to set root_dir in config so that this command:
      #   direnv exec ~/Documents/myenv jupyter lab start
      # always results in root_dir being ~/Documents/myenv.
      # If we don't, then running that command from $HOME makes root_dir be $HOME.
      # TODO: what is the filename supposed to be?
      #   jupyter_server_config.json
      #   jupyter_notebook_config.json
      #   jupyter_config.json
      #   jupyter_notebook_config.py
      if [ -f "$JUPYTER_CONFIG_DIR/jupyter_notebook_config.json" ]; then
        echo "File already exists: $JUPYTER_CONFIG_DIR/jupyter_notebook_config.json" >/dev/stderr
        exit 1
      fi
      echo '{"NotebookApp": {"root_dir": "${rootDirectoryImpure}"}}' >"$JUPYTER_CONFIG_DIR/jupyter_notebook_config.json"
    fi
    '';
  })
