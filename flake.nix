{
  description = "Lyzh's NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:serokell/deploy-rs";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-config.url = "github:imlyzh/home-manager";
    dotfiles = {
      url = "github:imlyzh/dotfiles";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, rust-overlay, deploy-rs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system: {
      apps.deploy = deploy-rs.apps.${system}.default;
    }) // {
      deploy = {
        nodes = {
          "lyzh-nixos-laptop" = {
            hostname = "lyzh-nixos";
            sshUser = "lyzh";
            useSudo = true;
            # buildOnTarget = true;
            # magicRollback = false;
            profiles = {
              system = {
                path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations."lyzh-nixos-laptop";
              };
            };
          };
        };
      };

      nixosConfigurations = {
        "lyzh-nixos-laptop" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              # home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.lyzh = {
                imports = [
                  (import "${home-config}/home/home.nix")
                  (import "${home-config}/home/shell.nix")
                  (import "${home-config}/home/dev.nix")
                  (import "${home-config}/home/docker.nix")
                  (import "${home-config}/home/linux-desktop-apps.nix")
                  ];
              };
            }
            ({ pkgs, ... }: {
              nixpkgs.overlays = [ rust-overlay.overlays.default ];
              environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
            })
          ];
        };
      };

      homeConfigurations = {
        "linux-desktop" = home-manager.lib.homeManagerConfiguration rec {
          extraSpecialArgs = { inherit inputs; };
          modules = [
            (import "${home-config}/home/home.nix")
            (import "${home-config}/home/shell.nix")
            (import "${home-config}/home/dev.nix")
            (import "${home-config}/home/docker.nix")
            (import "${home-config}/home/linux-desktop-apps.nix")
            ({ pkgs, ... }: {
            nixpkgs.overlays = [ rust-overlay.overlays.default ];
            environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
            })
            ];
        };

        "linux" = home-manager.lib.homeManagerConfiguration rec {
          extraSpecialArgs = { inherit inputs; };
          modules = [
            (import "${home-config}/home/home.nix")
            (import "${home-config}/home/shell.nix")
            (import "${home-config}/home/dev.nix")
            (import "${home-config}/home/docker.nix")
            ({ pkgs, ... }: {
            nixpkgs.overlays = [ rust-overlay.overlays.default ];
            environment.systemPackages = [ pkgs.rust-bin.stable.latest.default ];
            })
            ];
        };
      };
    };
}
