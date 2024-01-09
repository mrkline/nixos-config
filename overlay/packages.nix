{ pkgs, lib, config }:
{
    clip = pkgs.writeScriptBin "clip" ''
      #!${pkgs.stdenv.shell}
      ${pkgs.xclip}/bin/xclip -selection clipboard
    '';
}
