# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let unstable = (import <nixos-unstable> { config = { allowUnfree = true; }; }).pkgs;
in rec
{
  imports =
    [
      ./hardware-configuration.nix
      ./bbr.nix
      ./bfq.nix
      ./fonts.nix
    ];

  nixpkgs.config.allowUnfree = true;

  nix = {
      autoOptimiseStore = true;
  #  package = pkgs.nixFlakes;
  #  extraOptions = ''
  #    experimental-features = nix-command flakes
  #  '';
  };

  boot = {
      devShmSize = "10%";
      #kernelPackages = pkgs.linuxPackages_latest;
      kernelPackages = unstable.linuxPackages_latest;
      kernel.sysctl = {
        # REISUB
        "kernel.sysrq" = 1;

        # When we run out of memory, the kernel tries to flush all caches to disk
        # before invoking OOM. This tends to thrash the disk and lock up the system,
        # even if things aren't in swap.
        #
        # Have the killer kick in 512 MB early,
        # which gives us headroom to avoid freezing.
        "vm.admin_reserve_kbytes" = 524288;
      };
      tmpOnTmpfs = true; # tmpfs on /tmp please
  };

  # Set your time zone.
  time.timeZone = "US/Pacific";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  #networking.useDHCP = false;
  #networking.interfaces.eth0.useDHCP = true;
  #networking.interfaces.wlo1.useDHCP = true;
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mkline = {
    isNormalUser = true;
    home = "/home/mkline";
    description = "Matt Kline";
    extraGroups = [
      "dialout" # serial access
      "wheel" # sudo
      "networkmanager" # network conf
    ];
    shell = pkgs.zsh;
  };

  # Everyone loves docs!
  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    man.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     # Kernel-dependent stuff
     cudatoolkit
     compsize
     btrfs-progs
     boot.kernelPackages.bcc
     boot.kernelPackages.bpftrace
     boot.kernelPackages.perf

     # Nix fun
     nix-tree
     nix-index

     # disk stuff
     parted
     snapper

     # utils
     calc
     curl
     unstable.exa
     file
     htop
     killall
     moreutils
     pv
     simg2img # Android sparse image -> image conversion
     tmux
     tree
     usbutils
     wget
     vim # for xxd
     zsh

     # compression
     zip
     unzip
     gzip
     libarchive
     xz
     unstable.zstd

     # devel
     flamegraph
     bintools
     can-utils
     codespell
     colordiff
     dtc
     elfutils
     gnumake
     picocom
     unstable.clang
     unstable.gcc
     unstable.git
     unstable.man-pages
     unstable.neovim-unwrapped
     unstable.ripgrep

     # ...apps?
     evince
     unstable.firefox
     unstable.ffmpeg
     gimp
     gnome3.file-roller
     meld
     mpv
     optipng
     unstable.slack
     unstable.spotify
     unstable.zoom-us

     # ui/desktop environment
     unstable.alacritty
     conky
     globalprotect-openconnect
     gnome3.meld
     i3
     i3lock
     networkmanagerapplet
     pango
     pavucontrol
     picom
     rofi
     scrot
     xclip
     xfce.ristretto
     xfce.thunar
     xfce.tumbler
     xfce.xfce4-clipman-plugin
     xfce.xfce4-screenshooter
     xfce.xfce4-power-manager
     xfce.xfce4-notifyd
  ];

  powerManagement.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs = {

    zsh = {
      enable = true;
      enableCompletion = true;
    };
  };

  # Snapper: Snapshot /home hourly
  services = {
    globalprotect.enable = true;

    snapper= {
      configs = {
        home = {
          fstype = "btrfs";
          subvolume = "/home";
          extraConfig = ''
            ALLOW_USERS="mkline"
            TIMELINE_CREATE="yes"
            TIMELINE_CLEANUP="yes"
            TIMELINE_MIN_AGE="1800"
            TIMELINE_LIMIT_HOURLY="8"
            TIMELINE_LIMIT_DAILY="5"
            TIMELIME_LIMIT_WEEKLY="2"
            TIMELINE_LIMIT_MONTHLY="2"
            TIMELIME_LIMIT_YEARLY="0"
          '';
        };
      };
      snapshotInterval = "hourly";
    };

    picom.enable = true; # Use picom (compton fork) as the compositor
    openssh.enable = true; # Run OpenSSH
    fstrim.enable = true;

    xserver = {
      enable = true;
      autorun = true;
      desktopManager = {
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
        };
      };
      displayManager.defaultSession = "xfce+i3";

      windowManager.i3.enable = true;
      # Configure keymap in X11
      layout = "us";
      # Enable touchpad support (enabled default in most desktopManager).
      libinput.enable = true;
      # Enable 32-bit OGL stuff
      # hardware.opengl.driSupport32Bit = true;
    };
  };

  services.printing.enable = true;

  networking.firewall.enable = false;
}
