{ config, pkgs, lib, ... }:
let unstable = (import <nixos-unstable> { config = { allowUnfree = true; }; }).pkgs;
in
{
  boot = {
      kernelModules = [ "sg" ];
  };

  environment.systemPackages = with pkgs; [
     # Optional firmware
     alsa-firmware
     alsa-utils

     # disk stuff
     gparted


     # ...GUIs? Apps?
     crispy-doom
     evince
     file-roller
     filezilla
     gimp
     gnome-calculator
     gnupg
     haskellPackages.threadscope
     libreoffice
     meld
     mpv
     pinentry-qt
     qdirstat
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
  ];

  powerManagement.enable = true;

  programs = {
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  # GNOME, how we love thee
  services.gnome = {
    gnome-keyring.enable = true;
    gcr-ssh-agent.enable = false;
  };

  # In machine config!
  security.pam.services.lightdm-greeter.enableGnomeKeyring = true;

  security.pam.services.i3lock.enable = true;

  services = {
    displayManager.defaultSession = "xfce+i3";

    picom = { # Use picom (compton fork) as the compositor
      enable = true;
      backend = "glx";
      vSync = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      configPackages = [
        (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/44-multi-rates.conf" ''
          context.properties = {
            default.clock.allowed-rates = [ 44100 48000 ]
          }
        '')
      ];
    };

    printing.enable = true;
    printing.package = unstable.pkgs.cups;

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
}
