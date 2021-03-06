{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot = {
    loader.grub = {
      enable = true;
      efiSupport = true;
      devices = [ "nodev" ];
      # Grub is pokey at large resolutions. Use a smaller one.
      gfxmodeEfi = "1366x768";

      configurationLimit = 5;
    };

    loader.efi.canTouchEfiVariables = true;

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
  };

  networking.hostName = "kline-nixos-desktop"; # Define your hostname.

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

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
