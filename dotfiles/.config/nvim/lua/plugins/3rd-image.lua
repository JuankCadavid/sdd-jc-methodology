return {
  "3rd/image.nvim",
  dependencies = { "vhyrro/luarocks.nvim", "nvim-lua/plenary.nvim" },
  ft = { "image_nvim" },
  event = {
    "BufReadPre *.png",
    "BufReadPre *.jpg",
    "BufReadPre *.jpeg",
    "BufReadPre *.gif",
    "BufReadPre *.webp",
    "BufReadPre *.avif",
  },
  config = function()
    require("image").setup({
      integrations = {
        markdown = { enabled = false },
        neorg = { enabled = false },
        typst = { enabled = false },
        syslang = { enabled = false },
        html = { enabled = false },
        css = { enabled = false },
        org = { enabled = false },
        asciidoc = { enabled = false },
      },
    })
  end,
}
