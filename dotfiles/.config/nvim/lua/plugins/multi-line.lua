return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    init = function()
      -- Evita conflictos con atajos por defecto de LazyVim
      vim.g.VM_default_mappings = 0
      vim.g.VM_maps = {
        ["Find Under"] = "<C-n>",
        ["Add Cursor Down"] = "<M-j>",
        ["Add Cursor Up"] = "<M-k>",
        ["Select All"] = "<C-M-n>",
        ["Start Regex Search"] = "<C-M-/>",
        ["Visual All"] = "<C-M-n>",
      }
    end,
  },
}
