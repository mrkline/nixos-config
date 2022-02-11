{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Use GRUB as the bootloader
  boot.loader.grub = {
    enable = true;
    # It's a GPT/EFI system (not MBR)
    efiSupport = true;
    devices = [ "nodev" ];
    # Grub is pokey at large resolutions. Use a smaller one.
    gfxmodeEfi = "1366x768";

    configurationLimit = 5;
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  # The terminals are flaky with modesetting and the current hardware setup.
  boot.kernelParams = [ "nomodeset" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2a22dfdc-e68a-41af-893a-5004d667e34b";
      fsType = "btrfs";
      options = [ "compress-force=zstd" ];
    };

  boot.initrd.luks.devices."crypto-root" = {
    device = "/dev/disk/by-uuid/a6bfc5f1-de2e-4f2c-b387-09b8bccb0c93";
    allowDiscards = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/585D-2DC4";
    fsType = "vfat";
  };

  swapDevices = [ ];

  # powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
