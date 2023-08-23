return {
  -- Configure AstroNvim updates
  updater = {
    remote = "origin", -- remote to use
    channel = "stable", -- "stable" or "nightly"
    version = "latest", -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
    branch = "nightly", -- branch name (NIGHTLY ONLY)
    commit = nil, -- commit hash (NIGHTLY ONLY)
    pin_plugins = nil, -- nil, true, false (nil will pin plugins on stable only)
    skip_prompts = false, -- skip prompts about breaking changes
    show_changelog = true, -- show the changelog after performing an update
    auto_quit = false, -- automatically quit the current session after a successful update
    remotes = { -- easily add new remotes to track
      --   ["remote_name"] = "https://remote_url.come/repo.git", -- full remote url
      --   ["remote2"] = "github_user/repo", -- GitHub user/repo shortcut,
      --   ["remote3"] = "github_user", -- GitHub user assume AstroNvim fork
    },
  },

  -- Set colorscheme to use
  colorscheme = "tokyonight-storm",

  -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
  diagnostics = {
    virtual_text = true,
    underline = true,
  },

  lsp = {
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = false, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
  },

  -- Configure require("lazy").setup() options
  lazy = {
    defaults = { lazy = true },
    performance = {
      rtp = {
        -- customize default disabled vim plugins
        disabled_plugins = { "tohtml", "gzip", "matchit", "zipPlugin", "netrwPlugin", "tarPlugin" },
      },
    },
  },

  -- This function is run last and is a good place to configuring
  -- augroups/autocommands and custom filetypes also this just pure lua so
  -- anything that doesn't fit in the normal config locations above can go here
  polish = function()
    local function yaml_ft(_, bufnr)
      -- get content of buffer as string
      local content = vim.filetype.getlines(bufnr)
      if type(content) == "table" then content = table.concat(content, "\n") end

      local sam_regex = vim.regex "Transform:.*Resources:*"
      if sam_regex and sam_regex:match_str(content) then return "yaml.sam" end

      local cfn_regex = vim.regex "Resources:*"
      if cfn_regex and cfn_regex:match_str(content) then return "yaml.cfm" end

      -- return yaml if nothing else
      return "yaml"
    end

    vim.filetype.add {
      extension = {
        yml = yaml_ft,
        yaml = yaml_ft,
      },
    }

    vim.api.nvim_create_autocmd("FileType", {
      desc = "AWS CloudFormation YAML language server",
      group = vim.api.nvim_create_augroup("yaml_cfm", { clear = true }),
      pattern = "yaml.cfm",
      callback = function()
        require("lspconfig").yamlls.setup(
          require("astronvim.utils").extend_tbl(require("astronvim.utils.lsp").config "yamlls", {
            settings = {
              yaml = {
                schemas = {
                  [ "https://s3.amazonaws.com/cfn-resource-specifications-us-east-1-prod/schemas/2.15.0/all-spec.json" ] = "*-template.yaml"
                  },

                customTags = {
                  "!Cidr",
                  "!And",
                  "!And sequence",
                  "!If",
                  "!If sequence",
                  "!Not",
                  "!Not sequence",
                  "!Equals",
                  "!Equals sequence",
                  "!Or",
                  "!Or sequence",
                  "!GetAtt",
                  "!GetAtt sequence",
                  "!FindInMap",
                  "!FindInMap sequence",
                  "!Base64",
                  "!Join",
                  "!Join sequence",
                  "!Ref",
                  "!Sub",
                  "!Sub sequence",
                  "!GetAtt",
                  "!GetAZs",
                  "!ImportValue",
                  "!ImportValue sequence",
                  "!Select",
                  "!Select sequence",
                  "!Split",
                  "!Split sequence"
                  }
              }
            },

            filetypes = { "yaml.cfm" },
          })
        )
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      desc = "AWS SAM YAML language server",
      group = vim.api.nvim_create_augroup("yaml_sam", { clear = true }),
      pattern = "yaml.sam",
      callback = function()
        require("lspconfig").yamlls.setup(
          require("astronvim.utils").extend_tbl(require("astronvim.utils.lsp").config "yamlls", {
            settings = {
              yaml = {
                schemas = {
                  ["https://raw.githubusercontent.com/awslabs/goformation/master/schema/sam.schema.json"] = "/*.{yaml,yml}"
                  },

                customTags = {
                  "!Cidr",
                  "!And",
                  "!And sequence",
                  "!If",
                  "!If sequence",
                  "!Not",
                  "!Not sequence",
                  "!Equals",
                  "!Equals sequence",
                  "!Or",
                  "!Or sequence",
                  "!GetAtt",
                  "!GetAtt sequence",
                  "!FindInMap",
                  "!FindInMap sequence",
                  "!Base64",
                  "!Join",
                  "!Join sequence",
                  "!Ref",
                  "!Sub",
                  "!Sub sequence",
                  "!GetAtt",
                  "!GetAZs",
                  "!ImportValue",
                  "!ImportValue sequence",
                  "!Select",
                  "!Select sequence",
                  "!Split",
                  "!Split sequence"
                  }
              }
            },

            filetypes = { "yaml.sam" },
          })
        )
      end,
    })
  end,
}
