return {
    {
        "danymat/neogen",
        config = function()
            require('neogen').setup()
            vim.keymap.set(
                "n",
                "<Leader>nf",
                ":lua require('neogen').generate()<CR>",
                opts
            )
        end,
    }
}
