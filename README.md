# binder-nix-demo

minimal example of using nix w/ mybinder.org

```
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs &&     nix-channel --update &&             nix-shell default.nix
```

```
nix-prefetch-git https://github.com/nixos/nixpkgs.git refs/heads/nixos-unstable > nixpkgs-version.json
```

Test whether a package definition builds:

```
nix repl '<nixpkgs>'
pkgs = import <nixpkgs> { overlays=[(import ./python-overlay.nix)]; }
:b pkgs.python3Packages.callPackage ./nixpkgs/jupyter_server/default.nix {}
```

or alternatively:

```
nix repl '<nixpkgs>'
overlays = [(import ./python-overlay.nix)]
pkgs = import <nixpkgs> { inherit overlays; }
:b pkgs.python3Packages.callPackage ./nixpkgs/jupyter_server/default.nix {}
```

TODO:

- Get my jupyterlab extensions (JS) working. Related: [what jupyterWith says](https://github.com/tweag/jupyterWith#using-jupyterlab-extensions) about how they do this and [why](https://github.com/tweag/jupyterWith#about-extensions).
  -- Look into [Prebuilt Extensions](https://jupyterlab.readthedocs.io/en/stable/extension/extension_dev.html#prebuilt-extensions). Here's [an example](https://github.com/jtpio/jupyterlab-topbar/blob/main/setup.py) and [another](https://pypi.org/project/jupyterlab-hide-code/).
  -- [Common directories](https://jupyter.readthedocs.io/en/latest/use/jupyter-directories.html)
  -- [Jupyterlab directories](https://jupyterlab.readthedocs.io/en/stable/user/directories.html#jupyterlab-application-directory)
  -- `jupyter lab path`
  -- `jupyter --paths`
  -- `echo $JUPYTERLAB_DIR`
  -- [Extensions](https://github.com/jupyterlab/jupyterlab/blob/master/docs/source/user/extensions.rst#jupyterlab-application-directory)
- Figure out using NixOS andJupyterHub.
  -- [Discourse item](https://discourse.nixos.org/t/anyone-has-a-working-jupyterhub-jupyter-lab-setup/7659/2).
  -- [Module options](https://search.nixos.org/options?channel=20.09&show=services.jupyterhub.enable&from=0&size=50&sort=relevance&query=jupyter)
  -- [Module source code](https://github.com/NixOS/nixpkgs/blob/nixos-20.09/nixos/modules/services/development/jupyterhub/default.nix)
  -- [Issue for Jupyter init service](https://github.com/NixOS/nixpkgs/pull/33673k)

- What exactly does it mean to [use it as an overlay](https://github.com/tweag/jupyterWith#using-as-an-overlay)?

NOTES

See which ports are in use:

```
sudo lsof -i -P -n | grep LISTEN
```

Check for running jupyter notebooks:

```
jupyter notebook list
```

Check for running tmux sessions:

```
tmux ls
```

Symlink labextensions

```
ln -s /nix/store/8wbri9v2n9sx5dckbb5vybn35gb2v79q-python3.8-jupyterlab_hide_code-3.0.1/share/jupyter/labextensions/jupyterlab-hide-code share-jupyter/labextensions/jupyterlab-hide-code
```

```
mkdir @ryantam626/ && ln -s /nix/store/pbxbzkm03nmy2h84r1xbc8lbi3nyhcvp-python3.8-jupyterlab_code_formatter-1.4.3/lib/python3.8/site-packages/jupyterlab_code_formatter/labextension @ryantam626/jupyterlab_code_formatter
```

Full rebuild and check extensions:

```
mkdir -p share-jupyter/lab/staging/ && chmod -R +w share-jupyter/lab/staging/ && rm -rf share-jupyter .direnv/ && direnv allow
```

```
jupyter-serverextension list && jupyter-labextension list
```

Full rebuild and open notebook:

```
ssh nixos 'mkdir -p Documents/binder-nix-demo/share-jupyter/lab/staging && chmod -R +w Documents/binder-nix-demo/share-jupyter/lab/staging && rm -rf Documents/binder-nix-demo/.direnv Documents/binder-nix-demo/.virtual_documents Documents/binder-nix-demo/share-jupyter' && jupyterlab-connect nixos:Documents/binder-nix-demo
```
