
## first install nixos or nix

## usage in nixos
```sh
sudo nixos-rebuild switch --flake .#lyzh-nixos-laptop
```

## use nix cache

```
sudo nixos-rebuild switch --flake .#lyzh-nixos-laptop --option substituters 'http://lyzh-nixos-workstation:5000 https://cache.nixos.org/' --option trusted-public-keys '$(cat public.key) cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY='
```

## usage in home-manager(linux)
```sh
home-manager switch --flake .#linux
```

## remote push and build

```sh
nix run .#deploy .#lyzh-nixos-laptop -- --remote-build
```
