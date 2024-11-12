return {
    {
        'rebelot/kanagawa.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('kanagawa').setup({
                compile = false,         -- enable compiling the colorscheme
                undercurl = true,        -- enable undercurls
                commentStyle = { italic = true },
                keywordStyle = { italic = true },
                statementStyle = { bold = true },
                transparent = true,           -- do not set background color
                terminalColors = true,        -- define vim.g.terminal_color_{0,17}
                colors = {                    -- add/modify theme and palette colors
                    palette = {
                    },
                    theme = {
                        all = {
                            ui = {
                                bg_gutter = "none"
                            }
                        }
                    }
                },
                overrides = function(colors)        -- add/modify highlights
                    local theme = colors.theme
                    return {
                        NormalFloat = { bg = "none" },
                        FloatBorder = { bg = "none" },
                        FloatTitle = { bg = "none" },

                        -- Save an hlgroup with dark background and dimmed foreground
                        -- so that you can use it where your still want darker windows.
                        -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
                        NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

                        -- Popular plugins that open floats will link to NormalFloat by default;
                        -- set their background accordingly if you wish to keep them dark and borderless
                        LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
                        MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },

                        -- Telescope
                        TelescopeTitle = { fg = theme.ui.special, bold = true },
                        TelescopePromptNormal = { bg = "none" },
                        TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = "none" },
                        TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = "none" },
                        TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = "none" },
                        TelescopePreviewNormal = { bg = "none" },
                        TelescopePreviewBorder = { bg = "none", fg = theme.ui.bg_dim },

                        -- Cmp
                        Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 },  -- add `blend = vim.o.pumblend` to enable transparency
                        PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
                        PmenuSbar = { bg = theme.ui.bg_m1 },
                        PmenuThumb = { bg = theme.ui.bg_p2 },
                    }
                end,
            })

            vim.cmd("colorscheme kanagawa-wave")
        end
    },
}
