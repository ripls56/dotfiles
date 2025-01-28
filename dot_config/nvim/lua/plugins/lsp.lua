return {
    {
        {
            'VonHeikemen/lsp-zero.nvim',
            branch = 'v4.x',
            lazy = true,
            config = false,
        },
        {
            'williamboman/mason.nvim',
            lazy = false,
            opts = {},
        },

        -- Autocompletion
        {
            'hrsh7th/nvim-cmp',
            event = 'InsertEnter',
            config = function()
                local cmp = require('cmp')

                cmp.setup({
                    preselect = 'item',
                    sources = {
                        { name = 'nvim_lsp' },
                    },
                    window = {
                        completion = cmp.config.window.bordered(),
                        documentation = cmp.config.window.bordered(),
                    },
                    completion = {
                        completeopt = 'menu,menuone,noinsert'
                    },
                    mapping = cmp.mapping.preset.insert({
                        ['<C-Space>'] = cmp.mapping.complete(),
                        ['<CR>'] = cmp.mapping.confirm({ select = false }),
                        ['<C-j>'] = cmp.mapping(function(fallback)
                            local col = vim.fn.col('.') - 1

                            if cmp.visible() then
                                cmp.select_next_item({ behavior = 'select' })
                            elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                                fallback()
                            else
                                cmp.complete()
                            end
                        end, { 'i', 's' }),

                        -- Go to previous item
                        ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
                    }),
                    snippet = {
                        expand = function(args)
                            vim.snippet.expand(args.body)
                        end,
                    },
                })
            end
        },

        -- LSP
        {
            'neovim/nvim-lspconfig',
            cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
            event = { 'BufReadPre', 'BufNewFile' },
            dependencies = {
                { 'hrsh7th/cmp-nvim-lsp' },
                { 'williamboman/mason.nvim' },
                { 'williamboman/mason-lspconfig.nvim' },
            },
            init = function()
                -- Reserve a space in the gutter
                -- This will avoid an annoying layout shift in the screen
                vim.opt.signcolumn = 'yes'
            end,
            config = function()
                local lsp_defaults = require('lspconfig').util.default_config

                -- Add cmp_nvim_lsp capabilities settings to lspconfig
                -- This should be executed before you configure any language server
                lsp_defaults.capabilities = vim.tbl_deep_extend(
                    'force',
                    lsp_defaults.capabilities,
                    require('cmp_nvim_lsp').default_capabilities()
                )
                local buffer_autoformat = function(bufnr)
                    local group = 'lsp_autoformat'
                    vim.api.nvim_create_augroup(group, { clear = false })
                    vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })

                    vim.api.nvim_create_autocmd('BufWritePre', {
                        buffer = bufnr,
                        group = group,
                        desc = 'LSP format on save',
                        callback = function()
                            -- note: do not enable async formatting
                            vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
                        end,
                    })
                end
                -- LspAttach is where you enable features that only work
                -- if there is a language server active in the file
                vim.api.nvim_create_autocmd('LspAttach', {
                    desc = 'LSP actions',
                    callback = function(event)
                        local lsp_zero = require('lsp-zero')
                        local id = vim.tbl_get(event, 'data', 'client_id')
                        local client = id and vim.lsp.get_client_by_id(id)
                        if client == nil then
                            return
                        end
                        local opts = { buffer = event.buf }

                        if client.supports_method('textDocument/formatting') then
                            buffer_autoformat(event.buf)
                        end

                        if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                            vim.keymap.set('n', '<leader>th', function()
                                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(), { bufnr = event.buf })
                            end)
                        end

                        lsp_zero.highlight_symbol(client, bufnr)
                        lsp_zero.async_autoformat(client, bufnr)

                        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
                        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
                        vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
                        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
                        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
                        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
                        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
                        vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
                        vim.keymap.set({ 'n', 'x' }, '<leader>cf', '<cmd>lua vim.lsp.buf.format({async = true})<cr>',
                            opts)
                        vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
                    end,
                })

                require('mason').setup({})
                require('mason-lspconfig').setup({
                    preset = "recomended",
                    ensure_installed = {
                        'lua_ls',
                        'gopls',
                        'yamlls',
                        'rust_analyzer',
                    },
                    handlers = {
                        -- this first function is the "default handler"
                        -- it applies to every language server without a "custom handler"
                        function(server_name)
                            require('lspconfig')[server_name].setup({})
                        end,
                        yamlls = function()
                            require('lspconfig').yamlls.setup({
                                settings = {
                                    yaml = {
                                        schemas = {
                                            ["https://json.schemastore.org/github-workflow.json"] =
                                            "/.github/workflows/*",
                                        }
                                    }
                                }
                            })
                        end,
                        gopls = function()
                            require('lspconfig').gopls.setup({
                                settings = {
                                    gopls = {
                                        hints = {
                                            -- https://github.com/golang/tools/blob/master/gopls/doc/inlayHints.md
                                            assignVariableTypes = true,
                                            compositeLiteralFields = true,
                                            compositeLiteralTypes = true,
                                            constantValues = true,
                                            functionTypeParameters = true,
                                            parameterNames = true,
                                            rangeVariableTypes = true,
                                        },
                                        completeUnimported = true,
                                        usePlaceholders = true,
                                        analyses = {
                                            unusedparams = true,
                                        },
                                    },
                                }
                            })
                        end
                    }
                })
            end
        }
    }
}
