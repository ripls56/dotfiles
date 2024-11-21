return {
    {
        "danymat/neogen",
        config = function()
            require('neogen').setup()
            vim.keymap.set(
                "n",
                "<leader>nf",
                ":lua require('neogen').generate()<CR>",
                opts
            )
        end,
    }
}
