# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let unstable = (import <nixos-unstable> { config = { allowUnfree = true; }; }).pkgs;
in rec
{
  imports =
    [
      ./hardware-configuration.nix
      ./bbr.nix
      ./bfq.nix
      ./fonts.nix
      ./haskell.nix
      ./latex.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/42a168449605950935f15ea546f6f770e5f7f629.tar.gz"))
    (self: super: { mrkline = import ./overlay/packages.nix { inherit (self) config pkgs lib; }; })
  ];

  nix = {
    settings.auto-optimise-store = true;
    extraOptions = "experimental-features = flakes";
  };

  boot = {
      devShmSize = "20%";
      kernelModules = [ "sg" ];
      #kernelPackages = pkgs.linuxPackages_latest;
      kernelPackages = unstable.linuxPackages_latest;
      # MORE PREEMPTION FOR PREEMPTION GODS
      kernelParams = ["preempt=voluntary"];
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
      supportedFilesystems = [ "bcachefs" "ntfs" ];
      tmp.useTmpfs = true; # tmpfs on /tmp please
      tmp.tmpfsSize = "100%";
  };

  # Set your time zone.
  time.timeZone = "US/Pacific";

  networking = {
    nameservers = [ "8.8.8.8" ];
    networkmanager = {
      enable = true;
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "C.UTF-8";

  # Enable sound.
  sound.enable = true;

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
     unstable.bcachefs-tools
     btrfs-progs
     compsize
     #cudatoolkit

     # Optional firmware
     alsa-firmware
     alsa-utils

     # Nix fun
     nix-index
     nix-tree

     # disk stuff
     gparted
     parted
     snapper

     # compression
     gzip
     libarchive
     pixz
     unzip
     xz
     zip
     unstable.zstd

     # compilers, language-specific tooling
     clang
     gcc
     gdb
     haskellPackages.ghc-prof-flamegraph
     haskellPackages.hp2pretty
     haskellPackages.threadscope
     haskell-language-server
     hlint
     rust-bin.stable.latest.default
     rust-analyzer
     sqlite

     # other CLIs, utils
     acpi
     awscli
     backblaze-b2
     bintools
     binwalk
     calc
     can-utils
     cloc
     codespell
     colordiff
     curl
     dhcpcd
     dtc
     elfutils
     file
     flamegraph
     ghostscript
     graphviz
     htop
     iftop
     inotify-tools
     iotop
     iperf3
     isync
     jq
     kea
     killall
     lsof
     man-pages
     moreutils
     mosh
     msmtp
     mutt
     nmap
     optipng
     par
     pass
     patchelf
     picocom
     pinentry-qt
     pstree
     pv
     pwgen
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
     unstable.eza
     unstable.fd # find clone for nvim-fzf-commands
     unstable.ffmpeg-full
     unstable.fzf
     unstable.git-filter-repo
     unstable.neovim-unwrapped
     unstable.ripgrep
     unstable.typst
     unstable.yt-dlp

     # ...GUIs? Apps?
     element-desktop
     evince
     gimp
     globalprotect-openconnect
     gnome.file-roller
     gnome.gnome-calculator
     gnupg
     imagemagick
     libreoffice
     meld
     mpv
     spotify
     zathura
     zoom-us
     unstable.google-chrome
     unstable.firefox-bin
     unstable.discord
     unstable.signal-desktop
     unstable.slack

     # desktop environment
     alacritty
     conky
     feh
     i3
     i3lock
     lxappearance
     networkmanagerapplet
     pango
     pavucontrol
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

  ] ++ (builtins.attrValues pkgs.mrkline); # my crap

  powerManagement.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs = {
    git = {
      enable = true;
      package = unstable.pkgs.git;
      # Allow the LFS binary to be overridden in my work machine-local conf by
      # https://github.com/b-camacho/git-lfs/tree/bmc/add-fetchhead-fallback
      # until the LFS people feel like upstreaming it.
      lfs = { enable = true; package = lib.mkDefault unstable.pkgs.git-lfs; };
    };
    ssh = {
      startAgent = true;
      enableAskPassword = false;
    };
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
    };
  };

  security = {
    sudo = {
      package = pkgs.sudo.override { withInsults = true; };
      extraConfig = "Defaults insults";
    };
    rtkit.enable = true;
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  environment.etc."pipewire/pipewire.conf.d/rates.conf".text = ''
    context.properties = {
        default.clock.allowed-rates = [ 44100 48000 ]
        resample.quality = 10
    }
  '';


  services = {
    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };

    globalprotect.enable = true;

    # Snapper: Snapshot /home hourly
    snapper= {
      configs = {
        home = {
          FSTYPE = "btrfs";
          SUBVOLUME = "/home";
          ALLOW_USERS= ["mkline" "mrkline"];
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

    picom = { # Use picom (compton fork) as the compositor
      enable = true;
      backend = "glx";
      vSync = true;
    };

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
      desktopManager.wallpaper = {
        combineScreens = false;
        mode = "fill";
      };
      displayManager.defaultSession = "xfce+i3";

      windowManager.i3.enable = true;
      # Configure keymap in X11
      layout = "us";
      # Enable touchpad support (enabled default in most desktopManager).
      libinput.enable = true;
      libinput.touchpad.disableWhileTyping = true;
    };

  };

  hardware.opengl.enable = true;

  networking.firewall.enable = false;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 80;
  };
}
