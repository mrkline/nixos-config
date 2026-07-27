{ workBox, machineFiles }:
{ pkgs, ... }:
let
    # tree-sitter's vendored array.h grows an array by reassigning
    # `self->contents` through a generic `Array *`, so GCC is free to hoist
    # array_push's typed read-back above the realloc and write past the freed
    # buffer. nixpkgs builds every grammar at -O2 with strict aliasing on; the
    # haskell scanner corrupts the heap buffering a long block comment into
    # `lookahead`. Only grammars carrying the newer array.h are affected today
    # (haskell; c_sharp's older copy returns the pointer instead of punning),
    # but that's the form upstream ships now, so blanket it.
    # cf. patches/tree-sitter-haskell-fno-strict-aliasing.patch, which fixes
    # this for cargo consumers; buildGrammar compiles the C by hand and never
    # reads bindings/rust/build.rs.
    noStrictAliasing = g: g.overrideAttrs (o: {
        CFLAGS = o.CFLAGS ++ [ "-fno-strict-aliasing" ];
        CXXFLAGS = o.CXXFLAGS ++ [ "-fno-strict-aliasing" ];
    });
in {
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
            initContent = ''
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

                source <(COMPLETE=zsh jj)
            '';
        };
        git = {
            enable = true;
            lfs.enable = true;
            settings = {
                user.name = "Matt Kline";
                user.email = if workBox then "mkline@anduril.com" else "matt@bitbashing.io";
                alias = {
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
                merge.conflictStyle = "zdiff3";
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
            plugins = with pkgs.vimPlugins; [
                nvim-lspconfig
                vim-airline
                vim-airline-themes
                vim-fugitive
                nvim-fzf
                nvim-fzf-commands
                # markdown_inline handles inline markup (bold/links/code spans);
                # markdown alone only covers block structure.
                (nvim-treesitter.withPlugins (p: map noStrictAliasing [
                    p.c
                    p.c_sharp
                    p.cpp
                    p.haskell
                    p.json
                    p.lua
                    p.markdown
                    p.markdown_inline
                    p.nix
                    p.rust
                    p.toml
                    p.typst
                ]))
                ];
            extraConfig = builtins.readFile ./dotfiles/init.vim;
            withRuby = false;
            withPython3 = false;
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
        ".codex/AGENTS.md".text = ''
            Whenever there are multiple reasonable approaches to a problem,
            prompt the user instead of choosing one.
        '';
        ".config/alacritty/alacritty.toml".source = ./dotfiles/alacritty.toml;
        ".config/ghostty/config".source = ./dotfiles/ghostty;
        ".config/helix/config.toml".source = ./dotfiles/helix.toml;
        ".config/helix/languages.toml".source = ./dotfiles/helix-languages.toml;
        ".config/helix/themes/simpleton.toml".source = ./dotfiles/helix-themes/simpleton.toml;
        # Too lazy to plumb unstable in, so:
        # (see zsh config above also)
        ".config/jj/config.toml".text = ''
            [user]
            name = "Matt Kline"
            email = "${if workBox then "mkline@anduril.com" else "matt@bitbashing.io"}"

            [ui]
            conflict-marker-style = "git"
            diff-formatter = ":git"

            [aliases]
            blame = ["file", "annotate"]
            df = ["diff"]
            l = ["log"]
            la = ["log", "-r", "::"]
            lb = ["log", "-r", "trunk()..@"]
        '';
        ".config/nvim/lua/hls.lua".source = ./dotfiles/hls.lua;
        ".config/nvim/lua/treesitter.lua".source = ./dotfiles/treesitter.lua;
        ".config/waybar/config".source = ./sway/waybar-config;
        ".config/swaync/config.json".source = ./sway/swaync-config.json;
        ".config/swaync/style.css".source = ./sway/swaync-style.css;
        ".iftoprc".text = ''
            line-display: one-line-both
            show-bars: no
            show-totals: yes
        '';
    } // machineFiles);
    home.stateVersion = "24.05";
}
