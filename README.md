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
- Try to get my build system for jupyterlab extensions (JS) working.
