with builtins;
let
  # 21
  # terminal setting to make the Powerline prompt look OK:
  # {"fontFamily": "Meslo LG S DZ for Powerline,monospace"}

  # this corresponds to notebook_dir (impure)
  rootDirectoryImpure = toString ./.;
  shareDirectoryImpure = "${rootDirectoryImpure}/share-jupyter";
  jupyterlabDirectoryImpure = "${rootDirectoryImpure}/share-jupyter/lab";
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

  jupyterExtraPython = (pkgs.python3.withPackages (ps: with ps; [ 
    # Declare all server extensions in here, plus anything else needed.

    jupyter_lsp
    # jupyterlab-lsp must be specified here in order for the LSP for R to work.
    jupyterlab-lsp
    python-language-server

    # TODO: jupyterlab_code_formatter isn't working correctly.
    # It claims black and autopep8 aren't installed, even though they are.
    # And when I try isort as formatter, it does nothing.
    jupyterlab_code_formatter
    black
    isort
    autopep8

    jupytext
    jupyter_packaging
  ]));

  # From here, everything happens as in other examples.
  jupyter = pkgs.jupyterWith;

  #########################
  # R
  #########################

  myRPackages = p: with p; [
    formatR
    languageserver
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
    name = "irkernel_with_packages";
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

  # TODO: take a look at xeus-python
  # https://github.com/jupyter-xeus/xeus-python#what-are-the-advantages-of-using-xeus-python-over-ipykernel-ipython-kernel
  # It supports the jupyterlab debugger. But it's not packaged for nixos yet.

  iPython = jupyter.kernels.iPythonWith {
    name = "iPython_with_packages";
    packages = p: with p; [
      # TODO: nb_black is a 'python magic', not a serverextension. Since it is
      # intended for only for augmenting jupyter, where should I specify it?
      nb_black
      # TODO: compare nb_black with https://github.com/ryantam626/jupyterlab_code_formatter
      # One difference: this uses python magics (%), whereas jupyterlab_code_formatter
      # is an extension.

      # similar question for nbconvert
      nbconvert

      # non-Jupyter-specific packages

      numpy
      pandas

      beautifulsoup4
      soupsieve

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
      directory = jupyterlabDirectoryImpure;
      kernels = [ iPython irkernel ];
      extraPackages = p: [
        # needed by jupyterlab-connect
        p.ps
        p.lsof

        mynixpkgs.jupyterlab-connect

        # for nbconvert
        p.pandoc
        # see https://github.com/jupyter/nbconvert/issues/808
        #tectonic
        # more info: https://nixos.wiki/wiki/TexLive
        p.texlive.combined.scheme-full

        jupyterExtraPython

        # jupyterlab-lsp must be specified here in order for the LSP for R to work.
        # TODO: why isn't it enough that this is specified in jupyterExtraPython?
        p.python3Packages.jupyterlab-lsp

        # TODO: these dependencies are only required when it's necessary to
        # build a lab extension for from source.
        # Does jupyterWith allow me to specify them as buildInputs?
        p.nodejs
        p.yarn

        #################################
        # non-Jupyter-specific packages
        #################################

        p.imagemagick

        # to run AutoML Vision
        p.google-cloud-sdk

        p.exiftool

        # to get perceptual hash values of images
        # p.phash
        p.blockhash
      ];

      # TODO: how do we know it's python3.8 instead of another version like python3.9?
      extraJupyterPath = pkgs:
        concatStringsSep ":" [
          "${jupyterExtraPython}/lib/python3.8/site-packages"
        ];
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
    # TODO: is the following line ever useful?
    #export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt

    # set SOURCE_DATE_EPOCH so that we can use python wheels
    SOURCE_DATE_EPOCH=$(date +%s)

    export JUPYTERLAB_DIR="${jupyterlabDirectoryImpure}"
    export JUPYTER_CONFIG_DIR="${shareDirectoryImpure}/config"
    export JUPYTER_DATA_DIR="${shareDirectoryImpure}"
    export JUPYTER_RUNTIME_DIR="${shareDirectoryImpure}/runtime"

    mkdir -p "$JUPYTER_DATA_DIR"
    mkdir -p "$JUPYTER_RUNTIME_DIR"

    ##################
    # specify configs
    ##################

    rm -rf "$JUPYTER_CONFIG_DIR"
    mkdir -p "$JUPYTER_CONFIG_DIR"

    # TODO: which of way of specifying server configs is better?
    # 1. jupyter_server_config.json (single file w/ all jpserver_extensions.)
    # 2. jupyter_server_config.d/ (directory holding multiple config files)
    #                            jupyterlab.json
    #                            jupyterlab_code_formatter.json
    #                            ... 

    #----------------------
    # jupyter_server_config
    #----------------------
    # We need to set root_dir in config so that this command:
    #   direnv exec ~/Documents/myenv jupyter lab start
    # always results in root_dir being ~/Documents/myenv.
    # Otherwise, running that command from $HOME makes root_dir be $HOME.
    #
    # TODO: what is the difference between these two:
    # - ServerApp.jpserver_extensions
    # - NotebookApp.nbserver_extensions
    #
    # TODO: what's the point of the following check?
    if [ -f "$JUPYTER_CONFIG_DIR/jupyter_server_config.json" ]; then
      echo "File already exists: $JUPYTER_CONFIG_DIR/jupyter_server_config.json" >/dev/stderr
      exit 1
    fi
    #
    # If I don't include jupyterlab_code_formatter in
    # ServerApp.jpserver_extensions, I get the following error
    #   Jupyterlab Code Formatter Error
    #   Unable to find server plugin version, this should be impossible,open a GitHub issue if you cannot figure this issue out yourself.
    #
    echo '{"ServerApp": {"root_dir": "${rootDirectoryImpure}", "jpserver_extensions":{"nbclassic":true,"jupyterlab":true,"jupyterlab_code_formatter":true}}}' >"$JUPYTER_CONFIG_DIR/jupyter_server_config.json"

    #------------------------
    # jupyter_notebook_config
    #------------------------
    # The packages listed by 'jupyter-serverextension list' come from
    # what is specified in ./config/jupyter_notebook_config.json.
    # Yes, it does appear that 'server extensions' are indeed specified in
    # jupyter_notebook_config, not jupyter_server_config. That's confusing.
    #
    echo '{ "NotebookApp": { "nbserver_extensions": { "jupyterlab": true, "jupytext": true, "jupyter_lsp": true, "jupyterlab_code_formatter": true }}}' >"$JUPYTER_CONFIG_DIR/jupyter_notebook_config.json"

    #-------------------
    # widgetsnbextension
    #-------------------
    # Not completely sure why this is needed, but without it, things didn't work.
    mkdir -p "$JUPYTER_CONFIG_DIR/nbconfig/notebook.d"
    echo '{"load_extensions":{"jupyter-js-widgets/extension":true}}' >"$JUPYTER_CONFIG_DIR/nbconfig/notebook.d/widgetsnbextension.json"

    #################
    # lab extensions
    #################

    rm -rf "$JUPYTER_DATA_DIR/labextensions"
    mkdir -p "$JUPYTER_DATA_DIR/labextensions"

    #----------------------------------
    # symlink any source lab extensions
    #----------------------------------

    # A source lab extension is a raw JS package, and it must be compiled.
    # If we wanted to install jupyterlab_hide_code this way, we could try:
    #ln -s "${pkgs.python3Packages.jupyterlab_hide_code}/share/jupyter/labextensions/jupyterlab-hide-code" "$JUPYTER_DATA_DIR/labextensions/jupyterlab_hide_code"
    # Note that we'd have to run jupyter lab build for it to be available.
    # As this is currently set up, we would need to delete ./share-jupyter/lab
    # in order for the build to be run via this script.

    #------------------------------------
    # symlink any prebuilt lab extensions
    #------------------------------------

    # Note these are distributed via PyPI as "python" packages, even though
    # they are really JS, HTML and CSS.
    #
    # The symlink target will generally use snake-case, but maybe not always.
    #
    # The lab extension code appears to be in two places in the python packge:
    # - lib/python3.8/site-packages/snake_case_pkg_name/labextension
    # - share/jupyter/labextensions/dash-case-pkg-name
    # These directories are identical, except share/... has file install.json.

    # jupyterlab_hide_code
    #
    # When the symlink target is 'jupyterlab-hide-code' (dash case), the lab extension
    # works, but not when the symlink target is 'jupyterlab_hide_code' (snake_case).
    #
    # When using target share/..., the command 'jupyter-labextension list'
    # adds some extra info to the end:
    #   jupyterlab-hide-code v3.0.1 enabled OK (python, jupyterlab_hide_code)
    # When using target lib/..., we get just this:
    #   jupyterlab-hide-code v3.0.1 enabled OK
    # This difference could be due to the install.json being in share/...

    # @axlair/jupyterlab_vim
    mkdir -p "$JUPYTER_DATA_DIR/labextensions/@axlair"
    ln -s "${pkgs.python3Packages.jupyterlab_vim}/lib/python3.8/site-packages/jupyterlab_vim/labextension" "$JUPYTER_DATA_DIR/labextensions/@axlair/jupyterlab_vim"

    # @krassowski/jupyterlab-lsp
    mkdir -p "$JUPYTER_DATA_DIR/labextensions/@krassowski"
    ln -s "${pkgs.python3Packages.jupyterlab-lsp}/share/jupyter/labextensions/@krassowski/jupyterlab-lsp" "$JUPYTER_DATA_DIR/labextensions/@krassowski/jupyterlab-lsp"

    # @ryantam626/jupyterlab_code_formatter
    # The lab extension appears to load OK, but it returns 404 when I try to
    # format some code.
    # I also tried dash-case for the target, but that didn't work at all.
    #
    mkdir -p "$JUPYTER_DATA_DIR/labextensions/@ryantam626"
    ln -s "${pkgs.python3Packages.jupyterlab_code_formatter}/share/jupyter/labextensions/@ryantam626/jupyterlab_code_formatter" "$JUPYTER_DATA_DIR/labextensions/@ryantam626/jupyterlab_code_formatter"

    if [ ! -d "$JUPYTERLAB_DIR" ]; then
      mkdir -p "$JUPYTERLAB_DIR"

      ####################
      # build jupyter lab
      ####################

      # Note: we pipe stdout to stderr because otherwise $(cat "$\{dump\}")
      # would contain something that should not be evaluated.
      # Look for 'eval $(cat "$\{dump\}")' in ./.envrc file.
      jupyter lab build 1>&2

      # TODO: is the following ever needed? I used to think it was needed when
      # we wanted to install any source lab extensions.
      #chmod -R +w "${jupyterlabDirectoryImpure}/staging/"
      #jupyter lab build 2>&1
      #chmod -R -w "${jupyterlabDirectoryImpure}/staging/"
    fi
    '';
  })
