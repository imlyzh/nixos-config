{
  description = "Lyzh's NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rime-ice = {
      url = "github:iDvel/rime-ice";
      flake = false;
    };

    rime-without-ice = {
      url = "github:imlyzh/rime-without-ice";
      flake = false;
    };

    home-config.url = "github:imlyzh/home-manager";
    dotfiles = {
      url = "github:imlyzh/dotfiles";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, rust-overlay, home-manager, home-config, dotfiles, ... }@inputs:
    {
      nixosConfigurations = {
        "lyzh-great" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./machines/lyzh-great/configuration.nix
            home-manager.nixosModules.home-manager
            {
              # home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.lyzh = {
                imports = [
                  ({config, ...}: {
                    _module.args = {
                      dotfiles=dotfiles;
                    };
                  })
                  ({pkgs, ...}: {
                    nixpkgs.overlays = [ rust-overlay.overlays.default ];
                  })
                  (import "${home-config}/home/home.nix")
                  (import "${home-config}/home/shell.nix")
                  (import "${home-config}/home/shell-linux.nix")
                  (import "${home-config}/home/dev.nix")
                  (import "${home-config}/home/docker.nix")
                  # (import "${home-config}/home/desktop-apps.nix")
                  (import "${home-config}/home/linux-desktop-apps.nix")
                  (import "${home-config}/home/battlenet-games.nix")
                  ];
              };
              home-manager.backupFileExtension = "backup";
            }
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ rust-overlay.overlays.default ];
              environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
            })
          ];
        };
        "lyzh-nixos-laptop" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./machines/lyzh-nixos-laptop/configuration.nix
            # ./services/matrix-services.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.lyzh = {
                imports = [
                  ({config, ...}: {
                    _module.args = {
                      dotfiles=dotfiles;
                    };
                  })
                  ({pkgs, ...}: {
                    nixpkgs.overlays = [ rust-overlay.overlays.default ];
                  })
                  (import "${home-config}/home/home.nix")
                  (import "${home-config}/home/common.nix")
                  (import "${home-config}/home/linux-desktop-apps.nix")
                  (import "${home-config}/home/battlenet-games.nix")
                  ];
              };
              home-manager.backupFileExtension = "backup";
            }
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ rust-overlay.overlays.default ];
              environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
            })
          ];
        };
        "lyzh-nixos-workstation" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./machines/lyzh-nixos-workstation/configuration.nix
            ./services/matrix-services.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.lyzh = {
                imports = [
                  ({config, ...}: {
                    _module.args = {
                      dotfiles=dotfiles;
                    };
                  })
                  ({pkgs, ...}: {
                    nixpkgs.overlays = [ rust-overlay.overlays.default ];
                  })
                  (import "${home-config}/home/home.nix")
                  (import "${home-config}/home/common.nix")
                  (import "${home-config}/home/linux-desktop-apps.nix")
                  (import "${home-config}/home/battlenet-games.nix")
                  ];
              };
              home-manager.backupFileExtension = "backup";
            }
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ rust-overlay.overlays.default ];
              environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
            })
          ];
        };

      };
    };
}
