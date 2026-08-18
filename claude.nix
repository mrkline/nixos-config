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
        Programs and libraries are unlikely to be in standard Linux FHS locations,
        so if you want to run a particular command and it's not in `$PATH`,
        get it through `nix-shell`.

        Some repositories use jujutsu - use that instead of git when in such a repo.

        Never commit anything or take other actions to modify git or jj history on my behalf.
        Leave changes for me to review.
    '';
    mode = "0444";
  };
}
