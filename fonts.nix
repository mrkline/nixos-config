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
  fonts.fontconfig.enable = true;
  fonts.fontconfig.antialias = true;
  fonts.fontconfig.hinting.enable = true;
  fonts.fontconfig.defaultFonts.monospace = [ "mononoki" ];
}
