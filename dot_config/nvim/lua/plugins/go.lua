return {
    {
        'edolphin-ydf/goimpl.nvim',
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
            { 'nvim-lua/popup.nvim' },
            { 'nvim-telescope/telescope.nvim' },
            { 'nvim-treesitter/nvim-treesitter' },
        },
        config = function()
            require('telescope').load_extension('goimpl')

            vim.api.nvim_set_keymap('n', '<leader>im', [[<cmd>lua require('telescope').extensions.goimpl.goimpl{}<CR>]],
                { noremap = true, silent = true })
        end,
    },
    {
        "yanskun/gotests.nvim",
        ft = "go",
        opts = {},
    },
}
