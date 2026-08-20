return {
  {
    "olimorris/onedarkpro.nvim",
    version = "v2.28.0",
    lazy = false,
    priority = 1000,
    config = function()
      require("onedarkpro").setup({
        highlights = {
          Visual = {
            bg = "#333344",
            bold = true,
          },
          VisualNOS = {
            bg = "#333344",
            bold = true,
          },
	  NeoTreeCursorLine = {
            bg = "#333344",
	  },
        },
      })
      vim.cmd.colorscheme("onedark_dark")
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "lewis6991/gitsigns.nvim" },
    opts = function()
      local function git_status()
        local status = vim.b.gitsigns_status_dict
        if not status then
          return ""
        end

        local parts = {}
        if status.added and status.added > 0 then
          table.insert(parts, "+" .. status.added)
        end
        if status.changed and status.changed > 0 then
          table.insert(parts, "~" .. status.changed)
        end
        if status.removed and status.removed > 0 then
          table.insert(parts, "-" .. status.removed)
        end
        return table.concat(parts, " ")
      end

      local function git_branch()
        local status = vim.b.gitsigns_status_dict
        return status and status.head or ""
      end

      return {
        options = {
          icons_enabled = false,
          theme = "onedark",
          component_separators = "|",
          section_separators = "",
          globalstatus = false,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { git_branch, git_status },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "diagnostics", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      }
    end,
  },
}
