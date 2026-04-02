# Global claude settings
# Ideally these would live in home-manager,
# but the Claude TUI doesn't give an easy way to stitch together multiple files
# (e.g. some `settings.d/`)
#
let cs = {
  "\$schema" = "https://json.schemastore.org/claude-code-settings.json";
  permissions = {
    allow = [
      "Bash(git diff *)"
      "Bash(git log *)"
      "Bash(git ls-tree *)"
      "Bash(git show *)"
    ];
    deny = [
      "Bash(git commit *)"
      "Bash(git pull *)"
      "Bash(git push *)"
      "Bash(git remote *)"
      "Read(~/.ssh)"
      "Read(~/.zsh_history)"
    ];
  };
  env = {
    "CLAUDE_CODE_ENABLE_TELEMETRY" = "0";
  };
  spinnerVerbs = {
    mode = "replace";
    verbs = [
        "Baffling"
        "Cavitating"
        "Clanking"
        "Combobulating"
        "Concocting"
        "Cooking"
        "Cycle Stealing"
        "Dazzling"
        "Encabulating"
        "Extrapolating"
        "Extruding"
        "Fabricating"
        "Ginning"
        "Indexing"
        "Meandering"
        "Mippling"
        "Proceeding"
        "Reticulating Splines"
        "Scheming"
        "Side Fumbling"
        "Spoofing"
        "Staging"
        "Stewing"
        "Supposing"
        "Transmogrifying"
        "Traversing"
        "Wading"
        "Wandering"
        "Winding"
    ];
  };
};
in
{ ... }:
{
  environment.etc."claude-code/managed-settings.json" = {
    text = builtins.toJSON cs;
    mode = "0444";
  };
  environment.etc."claude-code/CLAUDE.md" = {
    text = ''
        You are running on a NixOS system.
        Programs and libraries are unlikely to be in standard Linux FHS locations.
        Do not search for them in `/nix/store/`, but instead prompt me if you cannot
        find what you're looking for - it is likely that I have forgotten to add it
        to the project's `shell.nix`. Whatever a project needs to build should be found
        in the `nix-shell`/`nix develop` environment that Claude Code is run inside of.
    '';
    mode = "0444";
  };
}
