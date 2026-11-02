{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-overlay = {
      url = "github:ryoppippi/nix-claude-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay/6b29b8e8d3cc8ebda9342fbbcc7ac06eff58e2fb";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixos-hardware,
      home-manager,
      claude-overlay,
      rust-overlay,
      nixos-wsl
  }:
  let
    mkSystem = machineModule: nixpkgs.lib.nixosSystem {
      specialArgs = { inherit nixos-hardware; };
      modules = [
        {
            nix.registry.nixpkgs.flake = nixpkgs;
            nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];
        }
        ({ pkgs, ... }: {
          _module.args.unstable = import nixpkgs-unstable {
            system = pkgs.stdenv.hostPlatform.system;
            config.allowUnfree = true;
          };
        })
        home-manager.nixosModules.home-manager
        nixos-wsl.nixosModules.default
        { nixpkgs.overlays = [
            rust-overlay.overlays.default
            claude-overlay.overlays.default
          ];
        }
        ./configuration.nix
        ./local.nix
        machineModule
      ];
    };
  in {
    nixosConfigurations = {
      thinkpad     = mkSystem ./thinkpad-hardware-configuration.nix;
      work-desktop = mkSystem ./work-desktop-hardware-configuration.nix;
      xps15        = mkSystem ./xps15-hardware-configuration.nix;
      utm          = mkSystem ./utm-hardware-configuration.nix;
      wsl          = mkSystem ./wsl.nix;
    };
  };
}
