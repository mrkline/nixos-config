# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  boot.kernelPackages = pkgs.linuxPackages_5_9; # Use the latest kernel
  boot.devShmSize = "10%";
  boot.tmpOnTmpfs = true; # tmpfs on /tmp please

  # Use BBR congestion control
  # https://en.wikipedia.org/wiki/TCP_congestion_control#TCP_BBR
  boot.kernelModules = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
  };

  networking.hostName = "kline-nixos-desktop"; # Define your hostname.

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

  services.xserver.enable = true;
  services.xserver.autorun = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.windowManager.i3.enable = true;
  # Configure keymap in X11
  services.xserver.layout = "us";
  # Enable touchpad support (enabled default in most desktopManager).
  #services.xserver.libinput.enable = true;
  # Enable 32-bit OGL stuff
  # hardware.opengl.driSupport32Bit = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mkline = {
    isNormalUser = true;
    home = "/home/mkline";
    description = "Matt Kline";
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     # disk stuff
     compsize
     btrfs-progs
     parted
     snapper

     # utils
     curl
     exa
     file
     killall
     tree
     wget
     htop

     # compression
     zsh
     zip
     unzip
     gzip
     libarchive
     xz
     zstd

     # devel
     git
     neovim
     ripgrep

     # ...apps?
     firefox
     ffmpeg
     gnome3.file-roller
     slack

     # ui/desktop environment
     alacritty
     conky
     i3
     i3lock
     networkmanagerapplet
     pango
     picom
     rofi
     scrot
     pavucontrol
     xclip
     xfce.ristretto
     xfce.thunar
     xfce.xfce4-clipman-plugin
     xfce.xfce4-screenshooter

     # Fonts
     dejavu_fonts
     jost
     mononoki
     source-code-pro
     source-sans-pro
     source-serif-pro
   ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.zsh.enable = true;
  programs.zsh.enableCompletion = true;

  # Snapper: Snapshot /home hourly
  services.snapper.configs = {
    home = {
      fstype = "btrfs";
      subvolume = "/home";
      extraConfig = ''
	ALLOW_USERS="mkline"
	TIMELINE_CREATE="yes"
	TIMELINE_CLEANUP="yes"
	TIMELINE_MIN_AGE="1800"
	TIMELINE_LIMIT_HOURLY="8"
	TIMELINE_LIMIT_DAILY="10"
	TIMELIME_LIMIT_WEEKLY="2"
	TIMELINE_LIMIT_MONTHLY="4"
	TIMELIME_LIMIT_YEARLY="1"
      '';
    };
  };
  services.snapper.snapshotInterval = "hourly";

  services.picom.enable = true; # Use picom (compton fork) as the compositor
  services.openssh.enable = true; # Run OpenSSH

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  fonts.fonts = with pkgs; [
    dejavu_fonts
    jost
    mononoki
    source-code-pro
    source-sans-pro
    source-serif-pro
  ];
  fonts.fontconfig.enable = true;
  fonts.fontconfig.antialias = true;
  fonts.fontconfig.hinting.enable = true;
  fonts.fontconfig.defaultFonts.monospace = [ "mononoki" ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
