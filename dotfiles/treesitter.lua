-- Tree-sitter based syntax highlighting.
-- Enable tree-sitter highlighting for every buffer whose filetype has a parser
-- available. Filetypes without a parser fall through to ye olde regex-based `syntax on`
vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        -- Some filetypes map to a differently-named parser (e.g. the `tex`
        -- filetype uses the `latex` parser); get_lang() resolves that.
        local lang = vim.treesitter.language.get_lang(ft) or ft
        -- language.add() loads the parser and returns nil (not an error) when
        -- none is installed for this language, so guard on its result.
        local ok, added = pcall(vim.treesitter.language.add, lang)
        if ok and added then
            vim.treesitter.start(args.buf, lang)
            -- Tree-sitter based folding for this window. Buffers without a
            -- parser keep the global foldmethod=syntax set in init.vim.
            -- (foldmethod/foldexpr are window-local; this window shows args.buf.)
            vim.wo.foldmethod = 'expr'
            vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        end
    end,
})
