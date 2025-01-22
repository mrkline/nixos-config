{ pkgs, ... }:
{
    # Newer versions are screwing up LFS and god knows what else
    nix.package = pkgs.nixVersions.nix_2_18;
}
