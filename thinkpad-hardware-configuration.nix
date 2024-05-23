# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
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
      "dialout" # serial access
      "wheel" # sudo
      "networkmanager" # network conf
      "wireshark"
    ];
    shell = pkgs.zsh;
  };

  security.pam.services.mrkline.enableGnomeKeyring = true;

  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 5;
      systemd-boot.consoleMode = "max";
      efi.canTouchEfiVariables = true;
    };
    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
      luks.devices."cryptoroot" = {
        device = "/dev/disk/by-uuid/90847ad2-7a40-46ca-a1a5-9d9fbd5a8fc7";
        allowDiscards = true;
      };
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/0fd841ce-5b00-42f6-8ebf-54aa23d77507";
      fsType = "btrfs";
      options = [ "subvol=root,compress-force=zstd" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/A8B2-13BF";
      fsType = "vfat";
    };
  };

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    opengl = {
      extraPackages = with pkgs; [
        intel-media-driver
        # vaapi-intel-hybrid # older? Let's try i-m-d first
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };

  networking.hostName = "mrkline-thinkpad";

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  services = {
    thinkfan.enable = true;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        USB_AUTOSUSPEND = "0";
      };
    };
  };

  swapDevices = [ ];

  environment.sessionVariables = {
      GDK_SCALE = "2.0";
      GDK_DPI_SCALE = "0.5";
  };
  services.xserver = {
    dpi = 200;
    # Everyone else is handled in XFCE DPI settings
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
