# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let unstable = (import <nixos-unstable> { config = { allowUnfree = true; }; }).pkgs;
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
    ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    (import (builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/2c7510a559416d07242621d036847152d970612b.tar.gz"))
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
      kernelPackages = pkgs.linuxPackages_latest;
      #kernelPackages = unstable.linuxPackages_latest;
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
      supportedFilesystems = [ "ntfs" ];
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
     btrfs-progs
     compsize
     #cudatoolkit

     # Nix fun
     cachix
     nix-index
     nix-output-monitor
     nix-tree

     # disk stuff
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
     unstable.cabal-install
     unstable.ghc
     unstable.hlint
     unstable.haskellPackages.cbor-tool
     unstable.haskellPackages.eventlog2html
     unstable.haskellPackages.ghc-events
     unstable.haskellPackages.ghc-prof-flamegraph
     unstable.haskellPackages.hp2pretty
     unstable.haskell-language-server

     # other CLIs, utils
     acpi
     awscli2
     backblaze-b2
     bat # cat clone for nvim-fzf-commands
     bintools
     binwalk
     calc
     cloc
     curl
     dhcpcd
     dtc
     elfutils
     eza
     fd # find clone for nvim-fzf-commands
     file
     flamegraph
     fzf
     ghostscript
     ghostty
     git-filter-repo
     graphviz
     htop
     iftop
     imagemagick
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
     neovim
     nmap
     optipng
     par
     pass
     patchelf
     perf
     picocom
     pstree
     pv
     pwgen
     rename
     ripgrep
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
     unstable.claude-code
     unstable.ffmpeg-full
     unstable.helix
     unstable.typst
     unstable.yt-dlp
  ] ++ (builtins.attrValues pkgs.mrkline); # my crap
  environment.pathsToLink = [ "/share/zsh" ]; # zsh completions
  environment.sessionVariables = {
    EDITOR = "nvim";
    LESS = "-x4RSX";
    # bat (syntax-highlighting cat) - white text on light term is bad, mmmk?
    BAT_THEME = "ansi";
    # ditto for fd (colorized find)
    LS_COLORS = "";
  };

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

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    chrony = {
      enable = true;
      # For UTM: chrony 4.7+ allows to sync with the RTC,
      # which MacOS keeps synced with its own time.
      # https://github.com/utmapp/UTM/issues/4644#issuecomment-2900887629
      package = unstable.pkgs.chrony;
    };


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

    openssh.enable = true; # Run OpenSSH
    fstrim.enable = false; # Async discard bb
  };

  networking.firewall.enable = false;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };
}
