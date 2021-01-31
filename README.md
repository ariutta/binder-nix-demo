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

- Try adding jupytext ([doc](https://github.com/tweag/jupyterWith#adding-packages-to-the-jupyter-path))
- What exactly does it mean to [use it as an overlay](https://github.com/tweag/jupyterWith#using-as-an-overlay)?
- Try to get my build system for jupyterlab extensions (JS) working. See also [what jupyterWith says](https://github.com/tweag/jupyterWith#using-jupyterlab-extensions) about how they do this and [why](https://github.com/tweag/jupyterWith#about-extensions).
  -- Look into [Prebuilt Extensions](https://jupyterlab.readthedocs.io/en/stable/extension/extension_dev.html#prebuilt-extensions). Here's [an example](https://github.com/jtpio/jupyterlab-topbar/blob/main/setup.py). Will require updating the [jupyterlab package](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/development/python-modules/jupyterlab/default.nix#L29) on nixpkgs to 3.0.6 or later.
