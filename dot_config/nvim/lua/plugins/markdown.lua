return {
  -- 1. Desbloquear y enriquecer render-markdown.nvim
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        enabled = true,
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        position = "overlay",
        width = "full",
        above = "▄",
        below = "▀",
      },
      code = {
        enabled = true,
        sign = false,
        style = "full",
        border = "thin",
        position = "left",
        language_icon = true,
        language_name = true,
        width = "block",
        min_width = 45,
        left_pad = 1,
        right_pad = 1,
      },
      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 " },
        checked = { icon = "󰄲 " },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        },
      },
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
      },
      pipe_table = {
        enabled = true,
        preset = "round",
        style = "full",
        padding = 1,
      },
      link = {
        enabled = true,
        hyperlink = "󰌹 ",
        image = "󰥶 ",
      },
      dash = {
        enabled = true,
        icon = "─",
        width = "full",
      },
    },
  },

  -- 2. Soporte para pegar imágenes desde el portapapeles directamente a markdown
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        dir_path = "assets",
        prompt_for_file_name = false,
        use_absolute_path = false,
      },
    },
    keys = {
      { "<leader>p", "<cmd>PasteImage<cr>", desc = "Pegar imagen desde portapapeles", ft = "markdown" },
    },
  },

  -- 3. Navegación fluida por tablas y checkboxes en markdown
  {
    "jakewvincent/mkdnflow.nvim",
    ft = { "markdown" },
    opts = {
      tables = {
        format_on_move = true,
        auto_set_mode = true,
      },
      links = {
        style = "markdown",
      },
      to_do = {
        symbols = { " ", "-", "x" },
      },
    },
  },
}
