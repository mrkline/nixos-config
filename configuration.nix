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
      ./latex.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"))
  ];

  nix = {
      settings.auto-optimise-store = true;
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
  };

  boot = {
      devShmSize = "10%";
      #kernelPackages = pkgs.linuxPackages_latest;
      kernelPackages = unstable.linuxPackages_latest;
      # MORE PREEMPTION FOR PREEMPTION GODS
      kernelParams = ["preempt=full"];
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

        # Experiment:
        # Let's see how disabling overcommit plays with zram,
        # or if it makes things die hard(er).
        # https://www.etalabs.net/overcommit.html
        "vm.overcommit_memory" = 2;
        "vm.overcommit_ratio" = 100;
      };
      tmp.useTmpfs = true; # tmpfs on /tmp please
  };

  # Set your time zone.
  time.timeZone = "US/Pacific";

  networking.networkmanager = {
    enable = true;
    dhcp = "dhcpcd";
    # Dongles
    unmanaged = [ "enp0s20f0u1" "enp0s20f0u2" ];
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "C.UTF-8";

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
      "wireshark"
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
     boot.kernelPackages.bcc
     boot.kernelPackages.bpftrace
     boot.kernelPackages.perf
     btrfs-progs
     compsize
     #cudatoolkit

     # Nix fun
     nix-index
     nix-tree

     # disk stuff
     parted
     snapper

     # utils
     acpi
     calc
     cloc
     curl
     dhcp
     dhcpcd
     file
     haskellPackages.cbor-tool
     htop
     inotify-tools
     iftop
     iotop
     iperf3
     jq
     killall
     lsof
     moreutils
     mosh
     nmap
     par
     pstree
     pv
     rename
     s-tui
     tinycbor
     tmux
     tree
     usbutils
     vim # for xxd
     vmtouch
     wget
     zsh
     unstable.bat # cat clone for nvim-fzf-commands
     unstable.exa
     unstable.fd # find clone for nvim-fzf-commands
     unstable.fzf

     # compression
     gzip
     libarchive
     pixz
     unzip
     xz
     zip
     unstable.zstd

     # devel
     awscli
     bintools
     binwalk
     can-utils
     clang_16
     codespell
     colordiff
     dtc
     elfutils
     flamegraph
     gcc
     gdb
     gnumake
     haskell-language-server
     hlint
     man-pages
     patchelf
     picocom
     rust-bin.stable.latest.default
     rust-analyzer
     unstable.git
     unstable.git-filter-repo
     unstable.git-lfs
     unstable.neovim-unwrapped
     unstable.ripgrep

     # ...apps?
     evince
     gimp
     gnome.file-roller
     gnome.gnome-calculator
     libreoffice
     meld
     mpv
     optipng
     zathura
     unstable.ffmpeg
     unstable.firefox-bin
     unstable.python3Packages.yt-dlp
     unstable.slack
     spotify
     unstable.teams
     unstable.zoom-us

     # ui/desktop environment
     alacritty
     conky
     globalprotect-openconnect
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
     xfce.xfce4-notifyd
     xfce.xfce4-power-manager
     xfce.xfce4-screenshooter
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
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
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
          FSTYPE = "btrfs";
          SUBVOLUME = "/home";
          ALLOW_USERS= ["mkline"];
          TIMELINE_CREATE = true;
          TIMELINE_CLEANUP = true;
          TIMELINE_MIN_AGE = "1800";
          TIMELINE_LIMIT_HOURLY = "8";
          TIMELINE_LIMIT_DAILY = "5";
          TIMELIME_LIMIT_WEEKLY = "2";
          TIMELINE_LIMIT_MONTHLY = "2";
          TIMELIME_LIMIT_YEARLY = "0";
        };
      };
      snapshotInterval = "hourly";
    };

    picom.enable = true; # Use picom (compton fork) as the compositor
    printing.enable = true;
    openssh.enable = true; # Run OpenSSH
    fstrim.enable = true;

    chrony.enable = true;

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
    };

  };

  hardware.opengl.enable = true;

  networking.firewall.enable = false;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };
}
