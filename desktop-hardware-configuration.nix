{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  users.users.mrkline = {
    isNormalUser = true;
    home = "/home/mrkline";
    description = "Matt Kline";
    extraGroups = [
      "dialout" # serial ports
      "wheel" # sudo
      "networkmanager" # network conf
      "wireshark"
    ];
    shell = pkgs.zsh;
  };

  boot = {
    loader.grub = {
      enable = true;
      efiSupport = true;
      devices = [ "nodev" ];
      configurationLimit = 5;
      extraEntries = ''
        menuentry "Video games and Redmond spyware" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --fs-uuid --set=root E05F-0604
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
    loader.efi.canTouchEfiVariables = true;
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "uas" "sd_mod" "sr_mod" ];
      kernelModules = [ ];
      luks.devices."cryptroot" = {
        device = "/dev/disk/by-uuid/96fc44de-1abe-4b8c-9b19-1c52a8aa7a40";
        allowDiscards = true;
      };
    };
    kernelModules = [ "kvm-amd" ];
    blacklistedKernelModules = [ "nouveau" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
        device = "/dev/disk/by-uuid/9e5acd16-fea1-4073-9d53-908361eb94ba";
        fsType = "btrfs";
        options = [ "subvol=root" ];
      };
    "/boot" = { 
      device = "/dev/disk/by-uuid/E05F-0604";
      fsType = "vfat";
    };
  };

  hardware = {
    enableAllFirmware = true;
    cpu.amd.updateMicrocode = true;
  };

  networking.hostName = "mrkline-desktop";

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  services.xserver.videoDrivers = [ "nvidia" ];

  swapDevices = [ ];

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
