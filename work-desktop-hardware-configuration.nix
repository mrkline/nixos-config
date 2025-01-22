{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  users.users.mkline = {
    isNormalUser = true;
    home = "/home/mkline";
    description = "Matt Kline";
    extraGroups = [
      "dialout" # serial access
      "docker"
      "wheel" # sudo
      "networkmanager" # network conf
      "wireshark"
    ];
    shell = pkgs.zsh;
  };
  home-manager.users.mkline = import ./home-manager.nix {
      workBox = true;
      machineFiles = {
          ".config/i3/conkyrc".source = ./i3/conkyrc;
          ".config/i3/config".source = ./i3/config;
      };
  };
  nix.settings.trusted-users = [ "root" "mkline" ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
      systemd-boot.consoleMode = "max";
      efi.canTouchEfiVariables = true;
    };

    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
      luks.devices."crypto-root" = {
        device = "/dev/disk/by-uuid/a6bfc5f1-de2e-4f2c-b387-09b8bccb0c93";
        allowDiscards = true;
      };
    };

    kernelModules = [ "kvm-intel" ];
    blacklistedKernelModules = [ "nouveau" ];
    extraModulePackages = [ ];
    # Make the Intel mobo the default sound card
    extraModprobeConfig = ''
      options snd slots=snd_hda_intel
    '';
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/2a22dfdc-e68a-41af-893a-5004d667e34b";
      fsType = "btrfs";
      options = [ "compress-force=zstd" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/585D-2DC4";
      fsType = "vfat";
    };
  };

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    nvidia.open = true;
  };

  networking.hostName = "kline-nixos-desktop"; # Define your hostname.

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  fonts.fontconfig.subpixel.lcdfilter = "default";
  fonts.fontconfig.subpixel.rgba = "rgb";

  services.xserver.videoDrivers = [ "nvidia" ];

  swapDevices = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
