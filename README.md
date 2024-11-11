# wormhole.nvim

`Wormhole.nvim` is a Neovim plugin designed to make navigating between multiple
open windows effortless. When activated, it spawns unique labels for each
window, allowing you to jump directly to any window by pressing the
corresponding label key. Ideal for users who work with numerous splits.

## 📺 Showcase

https://github.com/user-attachments/assets/a36022ca-9d42-4c16-8284-63bece18a4bb

## ⚡️ Requirements

- Neovim version >= 0.10.0

## 📋 Installation

> [!NOTE]
>
> - There is no need to call the `setup` function, only call it if you need to change some options
> - There is no need to lazy load `wormhole`, it lazy loads by default.

[lazy](https://github.com/folke/lazy.nvim):

```lua
return {
    "NStefan002/wormhole.nvim",
    lazy = false,
    version = "*",
}
```

[rocks.nvim](https://github.com/nvim-neorocks/rocks.nvim)

`:Rocks install wormhole.nvim`

## ⚙️ Configuration

- Default settings

```lua
require("wormhole").setup({
    labels_type = "home_row",
    custom_labels = {},
    label_highlight = { link = "IncSearch" },
})
```

| option | explanation |
| -------------- | --------------- |
| `labels_type` | Which characters to use for labels. Can be one of the following: `home_row`, `numbers`, `custom` |
| `custom_labels` | Array of custom labels to use. Only used if `labels_type` is set to `custom` |
| `label_highlight` | Options for highlight, see `:nvim_set_hl()` |

## ❓ How to use

- You need to set a keymap to activate the `wormhole` functionality. For example:

```lua
vim.keymap.set("n", "<leader>wl", "<Plug>(WormholeLabels)", { desc = "Wormhole Labels" })
vim.keymap.set("n", "<Esc>", "<Plug>(WormholeCloseLabels)", { desc = "Wormhole Close Labels" })
```

Or:

```lua
vim.keymap.set("n", "<c-s-i>", "<Plug>(WormholeLabelsToggle)", { desc = "Wormhole Labels Toggle" })
```

- Run `:checkhealth wormhole` to diagnose possible configuration problems
