{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    dejavu_fonts
    gyre-fonts
    jost
    mononoki
    noto-fonts
    noto-fonts-color-emoji
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
