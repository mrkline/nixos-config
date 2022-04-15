{ pkgs, ... }:
let
  tex = (pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-medium
    collection-latexextra
    collection-mathscience
    minted
    ;
  });
in
{
  environment.systemPackages = [ tex pkgs.python3Packages.pygments ];
}
