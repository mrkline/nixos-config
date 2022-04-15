{ pkgs, ... }:

{
  fonts.fonts = with pkgs; [
    dejavu_fonts
    jost
    mononoki
    noto-fonts
    noto-fonts-emoji
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
