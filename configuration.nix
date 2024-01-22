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
    (import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/2b24e1f369f00f5ae9876e15e12f77e12c9c2374.tar.gz"))
    (self: super: { mrkline = self.callPackage ./overlay/packages.nix { }; })
  ];

  nix.settings.auto-optimise-store = true;

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

     # utils
     acpi
     calc
     cloc
     curl
     dhcpcd
     file
     ghostscript
     htop
     inotify-tools
     iftop
     iotop
     iperf3
     jq
     kea
     killall
     lsof
     moreutils
     mosh
     nmap
     par
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
     haskellPackages.ghc-prof-flamegraph
     haskellPackages.hp2pretty
     haskellPackages.threadscope
     haskell-language-server
     hlint
     isync
     man-pages
     patchelf
     picocom
     rust-bin.stable.latest.default
     rust-analyzer
     sqlite
     unstable.git-filter-repo
     unstable.neovim-unwrapped
     unstable.ripgrep

     # ...apps?
     element-desktop
     evince
     gimp
     gnupg
     gnome.file-roller
     gnome.gnome-calculator
     imagemagick
     libreoffice
     meld
     mpv
     msmtp
     mutt
     optipng
     pass
     pinentry-qt
     zathura
     zoom-us
     unstable.ffmpeg-full
     unstable.firefox-bin
     unstable.discord
     unstable.yt-dlp
     unstable.signal-desktop
     unstable.slack
     spotify
     #unstable.teams

     # ui/desktop environment
     alacritty
     conky
     feh
     globalprotect-openconnect
     i3
     i3lock
     lxappearance
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

  ] ++ (
  with mrkline; [ # My crap
     colortest
     clip
     cp-reflink
     tt
  ]);

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
