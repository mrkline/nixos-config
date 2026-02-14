# Global claude settings
# Ideally these would live in home-manager,
# but the Claude TUI doesn't give an easy way to stitch together multiple files
# (e.g. some `settings.d/`)
#
let cs = {
  "\$schema" = "https://json.schemastore.org/claude-code-settings.json";
  permissions = {
    defaultMode = "plan";
    deny = [
      "Bash(git *)"
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
        "Clanking"
        "Combobulating"
        "Cooking"
        "Cycle Stealing"
        "Dazzling"
        "Encabulating"
        "Extruding"
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
        "Transmogrifying"
        "Traversing"
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
}
