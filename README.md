
## first install nixos or nix

## usage in nixos
```sh
sudo nixos-rebuild switch --flake .#
```

## usage in home-manager(linux)
```sh
home-manager switch --flake .#linux
```

## remote push and build

```sh
nix run .#deploy .#lyzh-nixos-laptop -- --remote-build
```