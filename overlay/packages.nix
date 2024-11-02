{ pkgs, lib, config }:
{
    clip = pkgs.writeScriptBin "clip" ''
      ${pkgs.xclip}/bin/xclip -selection clipboard
    '';

    colortest = pkgs.writeScriptBin "colortest" ''
      for color in $(seq 0 7); do
          printf %2d: $color
          echo -e "\\033[38;5;''${color}mhello\\033[48;5;''${color}mworld\\033[0m"

          lighter=$((color + 8))

          printf %2d: $(($lighter))
          echo -e "\\033[38;5;''${lighter}mhello\\033[48;5;''${lighter}mworld\\033[0m"
      done
    '';

    cp-reflink = pkgs.writeScriptBin "cp" ''
      ${pkgs.coreutils-full}/bin/cp --reflink=auto --sparse=auto "$@"
    '';

    tt = pkgs.writeScriptBin "tt" ''
      echo -e "\e]2;$1"
    '';
}
