{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Use GRUB as the bootloader
  boot.loader.grub.enable = true;
  # It's a GPT/EFI system (not MBR)
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.devices = [ "nodev" ];
  boot.loader.efi.canTouchEfiVariables = true;
  # Grub is pokey at large resolutions. Use a smaller one.
  boot.loader.grub.gfxmodeEfi = "1366x768";

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

  boot.initrd.luks.devices."crypto-root".device = "/dev/disk/by-uuid/a6bfc5f1-de2e-4f2c-b387-09b8bccb0c93";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/585D-2DC4";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
