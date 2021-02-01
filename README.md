# binder-nix-demo

minimal example of using nix w/ mybinder.org

```
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs &&     nix-channel --update &&             nix-shell default.nix
```

```
nix-prefetch-git https://github.com/nixos/nixpkgs.git refs/heads/nixos-unstable > nixpkgs-version.json
```

```
nix repl '<nixpkgs>'
pkgs = import <nixpkgs> { overlays=[(import ./python-overlay.nix)]; }
#overlays = [(import ./python-overlay.nix)]
#pkgs = import <nixpkgs> { inherit overlays; }
:b pkgs.python3Packages.callPackage ./nixpkgs/jupyter-server/default.nix {}
```

TODO:

- Get my jupyterlab extensions (JS) working. Related: [what jupyterWith says](https://github.com/tweag/jupyterWith#using-jupyterlab-extensions) about how they do this and [why](https://github.com/tweag/jupyterWith#about-extensions).
  -- Look into [Prebuilt Extensions](https://jupyterlab.readthedocs.io/en/stable/extension/extension_dev.html#prebuilt-extensions). Here's [an example](https://github.com/jtpio/jupyterlab-topbar/blob/main/setup.py) and [another](https://pypi.org/project/jupyterlab-hide-code/).
- Enable tests where possible for packages in ./nixpkgs.

- What exactly does it mean to [use it as an overlay](https://github.com/tweag/jupyterWith#using-as-an-overlay)?
