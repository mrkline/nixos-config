# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
      ./desktop.nix
      ./work.nix
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
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ ];
      luks.devices."crypto-root" = {
        device = "/dev/disk/by-uuid/7cdc673f-4b6e-4673-b992-561f6c66c57f";
        allowDiscards = true;
      };
    };
    #kernelModules = [ "kvm-intel" ];
    blacklistedKernelModules = [ "nouveau" ];
    kernelParams = [ "i915.enable_psr=0" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" =
      { device = "/dev/disk/by-uuid/e481fdb1-06b5-4c8d-a42b-29939b57c070";
        fsType = "btrfs";
        options = [ "subvol=root" "compress-force=zstd" ];
      };

    "/boot" =
      { device = "/dev/disk/by-uuid/C51A-2E92";
        fsType = "vfat";
      };
  };

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = false;
    bluetooth.powerOnBoot = false;
  };

  networking.hostName = "mrkline-nixos-laptop"; # Define your hostname.

  # I'll take care of the dongles.
  networking.networkmanager.unmanaged = [ "interface-name:enp*" ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  fonts.fontconfig.subpixel.lcdfilter = "default";
  fonts.fontconfig.subpixel.rgba = "rgb";

  services = {
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        USB_AUTOSUSPEND = "0";
      };
    };
    xserver = {
      videoDrivers = [ "modesetting" ];
    };
  };

  hardware.graphics = {
    extraPackages = with pkgs; [ intel-media-driver mesa.drivers ];
  };

  swapDevices = [ ];

  system.stateVersion = "21.11";
}
