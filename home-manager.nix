{ workBox, machineFiles }:
let unstable = (import <nixos-unstable> { config = { allowUnfree = true; allowBroken = true; }; }).pkgs;
in { pkgs, ... }: {
    programs = {
        zsh = {
            enable = true;
            enableCompletion = true;
            defaultKeymap = "emacs";
            history = {
                expireDuplicatesFirst = true;
                extended = true;
                ignoreDups = true;
                ignoreSpace = true;
                save = 1000000000;
                size = 1000000000;
                share = true;
            };
            shellAliases = {
                grep = "grep --color=auto";
                ls = "ls --color=auto";

                # Useful commands
                dmap = "tree --du -h --dirsfirst --sort=size";
                lss = "ls -lShr";
                lst = "ls -lthr";
                el = "eza -lh";
                es = "eza -lhs size";
                ed = "eza -lhs date";
                e1 = "eza -1";

                # Patience diff is best diff
                pdiff = "git diff --patience --no-index";

                # Self-deprecating humor
                ":w" = "echo E_NOTVIM";
                ":wq" = "echo E_I_AM_A_SHELL";
                ":q" = "echo In Russia, shell quits you!";
                ":qa" = "echo No escape";

                # ...
                rot13 = "tr '[A-Za-z]' '[N-ZA-Mn-za-m]'";
            };
            initExtra = ''
                # Muh prompt:
                export PS1='%F{red}%(?..[%?] )%f%F{green}%~%f $ '
                export RPS1=""

                bindkey '^[[1;5C' forward-word # [Ctrl-RightArrow] - move forward one word
                bindkey '^[[1;5D' backward-word # [Ctrl-LeftArrow] - move backward one word

                # This implements a bash-style backward-kill-word.
                function bash-backward-kill-word {
                    local WORDCHARS=""
                    zle .backward-kill-word
                }

                zle -N bash-backward-kill-word
                bindkey '^W' bash-backward-kill-word
            '';
        };
        git = {
            enable = true;
            userName = "Matt Kline";
            userEmail = if workBox then "mkline@anduril.com" else "matt@bitbashing.io";
            lfs.enable = true;
            aliases = {
                graph = "log --graph --oneline --decorate";
                ff = "merge --ff-only";
                zip = "archive --format=zip";
                dt = "difftool";
                ga = "log --oneline --decorate --graph --all";
                gr = "log --oneline --decorate --graph";
                co = "checkout";
                ci = "commit";
                st = "status";
                df = "diff";
                cam = "commit --amend";
                append = "commit --amend --no-edit";
            };
            extraConfig = {
                core = {
                    autocrlf = false;
                    compression = 0;
                };
                color = {
                    ui = "auto";
                };
                diff = {
                    tool = "meld";
                    algorithm = "patience";
                    submodule = "short";
                };
                fetch = {
                    prune = "true";
                    writeCommitGraph = "true";
                };
                push = {
                    default = "current";
                    recurseSubmodules = "check";
                };
                gc = {
                    autoDetach = false;
                    auto = 0;
                };
                init.defaultBranch = "master";
            };
        };
        neovim = {
            enable = true;
            package = unstable.neovim-unwrapped;
            plugins = [ unstable.vimPlugins.vim-plug ];
            extraConfig = builtins.readFile ./dotfiles/init.vim;
        };
        fzf = {
            enable = true;
            enableZshIntegration = true;
        };
    };
    home.file = ({
        ".cargo/config.toml".text = ''
            [build]
            rustflags = ["-C", "force-frame-pointers=true" ]

            [profile.dev]
            opt-level = 2
        '';
        ".config/alacritty/alacritty.toml".source = ./dotfiles/alacritty.toml;
        ".config/nvim/lua/hls.lua".source = ./dotfiles/hls.lua;
        ".config/i3/conky".source = ./i3/conky;
        ".iftoprc".text = ''
            line-display: one-line-both
            show-bars: no
            show-totals: yes
        '';
    } // machineFiles);
    home.stateVersion = "24.05";
}
