return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    table.insert(opts.sections.lualine_x, {
      function()
        return "AWS: " .. (vim.env.AWS_PROFILE or "default")
      end,
      icon = "  ", -- Requires a Nerd Font
      color = { fg = "#ff9900" }, -- AWS orange
    })
  end,
}
