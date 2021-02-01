{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
     # Fonts
     dejavu_fonts
     jost
     mononoki
     source-code-pro
     source-sans-pro
     source-serif-pro
   ];

  fonts.fonts = with pkgs; [
    dejavu_fonts
    jost
    mononoki
    source-code-pro
    source-sans-pro
    source-serif-pro
  ];
  fonts.fontconfig = {
    enable = true;
    antialias = true;
    hinting.enable = true;
    defaultFonts.monospace = [ "mononoki" ];
  };
}
