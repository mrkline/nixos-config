{ config, lib, pkgs, modulesPath, ... }:

let unstable = (import <nixos-unstable> { config = { allowUnfree = true; }; }).pkgs;
in {
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  users.users.mkline = {
    isNormalUser = true;
    home = "/home/mkline";
    description = "Matt Kline";
    extraGroups = [
      "dialout" # serial access
      "wheel" # sudo
      "networkmanager" # network conf
      "wireshark"
    ];
    shell = pkgs.zsh;
  };

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
    # The terminals are flaky with modesetting and the current hardware setup.
    kernelParams = [ "nomodeset" ];
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

  # TODO: Get the password to bcachefs via normal NixOs mount machinery
  systemd.services.mount-rotating-rust = {
    enable = true;
    description = "Mount bcachefs to /rust";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${unstable.bcachefs-tools}/bin/bcachefs mount -k ask /dev/disk/by-uuid/c9393593-e940-4af5-8b2b-e6d8d4c23146 /rust";
      StandardInput="file:/home/bcache.pass";
      Restart = "no";
    };
    wantedBy = [ "multi-user.target" ];
  };

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
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
