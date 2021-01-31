# binder-nix-demo

minimal example of using nix w/ mybinder.org

```
nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs &&     nix-channel --update &&             nix-shell default.nix
```

```
nix-prefetch-git https://github.com/nixos/nixpkgs.git refs/heads/nixos-unstable > nixpkgs-version.json
```

TODO:

- Try adding jupytext ([doc](https://github.com/tweag/jupyterWith#adding-packages-to-the-jupyter-path))
- What exactly does it mean to [use it as an overlay](https://github.com/tweag/jupyterWith#using-as-an-overlay)?
- Try to get my build system for jupyterlab extensions (JS) working. See also [what jupyterWith says](https://github.com/tweag/jupyterWith#using-jupyterlab-extensions) about how they do this and [why](https://github.com/tweag/jupyterWith#about-extensions).
- Add the rest of the dependencies I have in pathway-figure-ocr.
