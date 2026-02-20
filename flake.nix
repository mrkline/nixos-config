{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, rust-overlay, nixos-wsl }:
  let
    mkSystem = machineModule: nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          _module.args.unstable = import nixpkgs-unstable {
            system = pkgs.stdenv.hostPlatform.system;
            config.allowUnfree = true;
          };
        })
        home-manager.nixosModules.home-manager
        nixos-wsl.nixosModules.default
        { nixpkgs.overlays = [ rust-overlay.overlays.default ]; }
        ./configuration.nix
        ./local.nix
        machineModule
      ];
    };
  in {
    nixosConfigurations = {
      thinkpad     = mkSystem ./thinkpad-hardware-configuration.nix;
      desktop      = mkSystem ./desktop-hardware-configuration.nix;
      work-desktop = mkSystem ./work-desktop-hardware-configuration.nix;
      xps15        = mkSystem ./xps15-hardware-configuration.nix;
      utm          = mkSystem ./utm-hardware-configuration.nix;
      wsl          = mkSystem ./wsl.nix;
    };
  };
}
