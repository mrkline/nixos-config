{ config, pkgs, lib, unstable, ... }:
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
     cinny-desktop
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
     adwaita-icon-theme
     alacritty
     brightnessctl
     grim
     networkmanagerapplet
     pango
     pwvucontrol
     rofi
     slurp
     swaylock
     waybar
     wl-clipboard
     xfce.ristretto
     xfce.thunar
     xfce.tumbler
     xfce.xfce4-notifyd
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  powerManagement.enable = true;

  programs = {
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
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

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  security.pam.services.swaylock = {};
  security.pam.services.greetd.enableGnomeKeyring = true;

  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
          user = "greeter";
        };
      };
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
  };

  hardware.graphics.enable = true;
}
