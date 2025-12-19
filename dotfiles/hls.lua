function whichHls()
    handle = io.popen("which haskell-language-server")
    which = handle:read("*a")
    which = which:gsub('%s+', '')
    io.close(handle)
    if which == "" then
        which = "haskell-language-server-wrapper"
    end
    return which;
end

hls = whichHls()
vim.lsp.config('hls', {
    cmd = { hls, "--lsp" },
    settings = {
        haskell = {
            hlintOn = true
        }
    }
})
vim.lsp.enable('hls')
