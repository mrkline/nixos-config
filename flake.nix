{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-overlay = {
      url = "github:ryoppippi/nix-claude-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay/475826b105eb52f39bd3281f60c052299e64d085";
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
