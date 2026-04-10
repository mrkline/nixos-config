{ pkgs, lib, config }:
{
    clip = pkgs.writeScriptBin "clip" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.wl-clipboard}/bin/wl-copy
    '';

    lock = pkgs.writeScriptBin "lock.sh" ''
      #!${pkgs.bash}/bin/bash
      set -e
      me="$(whoami)"
      ss=/tmp/"$me"_screens.png
      bg=/tmp/"$me"_lock_background.png
      # Don't let other users access a screenshot of your system
      umask 066
      ${pkgs.grim}/bin/grim "$ss"
      # Use ffmpeg instead of convert/mogrify because it uses these crazy things
      # called threads (and gives you finer control over the scaling).
      ${pkgs.ffmpeg-full}/bin/ffmpeg -y -v error -i "$ss" -vf "scale=in_w/10:-1:flags=area,scale=10*in_w:-1:flags=neighbor" "$bg"
      ${pkgs.swaylock}/bin/swaylock -f -i "$bg"
      rm "$ss" "$bg"
    '';

    colortest = pkgs.writeScriptBin "colortest" ''
      #!${pkgs.bash}/bin/bash
      for color in $(seq 0 7); do
          printf %2d: $color
          echo -e "\\033[38;5;''${color}mhello\\033[48;5;''${color}mworld\\033[0m"

          lighter=$((color + 8))

          printf %2d: $(($lighter))
          echo -e "\\033[38;5;''${lighter}mhello\\033[48;5;''${lighter}mworld\\033[0m"
      done
    '';

    cp-reflink = pkgs.writeScriptBin "cp" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.coreutils-full}/bin/cp --reflink=auto --sparse=auto "$@"
    '';

    tt = pkgs.writeScriptBin "tt" ''
      #!${pkgs.bash}/bin/bash
      echo -e "\e]2;$1"
    '';
}
