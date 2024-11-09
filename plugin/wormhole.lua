if vim.g.loaded_wormhole then
    return
end

vim.g.loaded_wormhole = true

local api = vim.api

api.nvim_create_autocmd("WinClosed", {
    pattern = "*",
    group = api.nvim_create_augroup("WormholeGrp", {}),
    callback = function(ev)
        local L = require("wormhole.labels")
        local U = require("wormhole.util")

        if #U.get_map_keys(L.active_labels) == 0 then
            return
        end

        local closed_winnr = tonumber(ev.match)
        if closed_winnr == nil then
            return
        end

        if L.active_labels[closed_winnr] == nil then
            return
        end

        -- TODO: do we need this?
        -- vim.keymap.del(
        --     "n",
        --     L.active_labels[closed_winnr].label,
        --     { buffer = L.active_labels[closed_winnr].bufnr }
        -- )
        print(L.active_labels[closed_winnr].label)
        api.nvim_win_close(L.active_labels[closed_winnr].winnr, true)
        api.nvim_buf_delete(L.active_labels[closed_winnr].bufnr, { force = true })
        L.active_labels[closed_winnr] = nil
    end,
    desc = "Remove labels when a window is closed",
})

vim.keymap.set("n", "<Plug>(WormholeLabels)", function()
    require("wormhole.labels").create_labels()
end, { noremap = true })
