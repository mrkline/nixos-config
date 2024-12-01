# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let unstable = (import <nixos-unstable> { config = { allowUnfree = true; allowBroken = true; }; }).pkgs;
in rec
{
  imports =
    [
      <home-manager/nixos>
      ./hardware-configuration.nix
      ./bbr.nix
      ./bfq.nix
      ./fonts.nix
      ./haskell.nix
      ./latex.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/c65e91d4a33abc3bc4a892d3c5b5b378bad64ea1.tar.gz"))
    (self: super: { mrkline = import ./overlay/packages.nix { inherit (self) config pkgs lib; }; })
  ];

  nix = {
    settings.auto-optimise-store = true;
    extraOptions = ''
        experimental-features = nix-command fetch-closure flakes
        builders-use-substitutes = true
    '';
  };

  boot = {
      devShmSize = "20%";
      kernelModules = [ "sg" ];
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
     cachix
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
     gdb
     rust-bin.stable.latest.default
     rust-analyzer
     sqlite
     unstable.ghc
     unstable.hlint
     unstable.haskellPackages.cbor-tool
     unstable.haskellPackages.ghc-prof-flamegraph
     unstable.haskellPackages.hp2pretty
     unstable.haskellPackages.threadscope
     unstable.haskell-language-server

     # other CLIs, utils
     acpi
     awscli
     backblaze-b2
     bintools
     binwalk
     calc
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
     mdbook
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
     viu
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
     crispy-doom
     element-desktop
     evince
     file-roller
     filezilla
     gimp
     gnome-calculator
     gnupg
     imagemagick
     libreoffice
     meld
     mpv
     pinentry-qt
     seahorse
     spotify
     zathura
     zoom-us
     unstable.google-chrome
     unstable.firefox
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
  environment.pathsToLink = [ "/share/zsh" ]; # zsh completions
  environment.sessionVariables = {
    EDITOR = "nvim";
    # Saves some stat() calls, FWIW:
    # https://blog.packagecloud.io/eng/2017/02/21/set-environment-variable-save-thousands-of-system-calls/
    TZ = ":/etc/localtime";
    LESS = "-x4RSX";
    # bat (syntax-highlighting cat) - white text on light term is bad, mmmk?
    BAT_THEME = "ansi";
    # ditto for fd (colorized find)
    LS_COLORS = "";
  };

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
    # We use gnome-keyring below, but it only starts --components=secrets. Keep up the ssh-agent.
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

  # GNOME, how we love thee
  services.gnome.gnome-keyring.enable = true;
  # In machine config!
  security.pam.services.lightdm.enableGnomeKeyring = true;


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
    configPackages = [
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/44-multi-rates.conf" ''
        context.properties = {
          default.clock.allowed-rates = [ 44100 48000 ]
          resample.quality = 10
        }
      '')
    ];
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
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
          TIMELIME_LIMIT_WEEKLY = "0";
          TIMELINE_LIMIT_MONTHLY = "0";
          TIMELIME_LIMIT_YEARLY = "0";
        };
      };
      persistentTimer = true;
      snapshotInterval = "hourly";
    };

    picom = { # Use picom (compton fork) as the compositor
      enable = true;
      backend = "glx";
      vSync = true;
    };

    printing.enable = true;
    openssh.enable = true; # Run OpenSSH

    chrony.enable = true;

    displayManager.defaultSession = "xfce+i3";

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

      windowManager.i3.enable = true;
      # Configure keymap in X11
      xkb.layout = "us";
    };

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;
    libinput.touchpad.disableWhileTyping = true;

  };

  hardware.graphics.enable = true;

  networking.firewall.enable = false;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };
}
