local api = vim.api
local config = require("wormhole.config")
local util = require("wormhole.util")

local M = {}

---Map of window ids to labels win/buf ids
---@type table<integer, { label: string, winnr: integer, bufnr: integer }>
M.active_labels = {}

---@type string[]
M.home_row_labels = { "h", "j", "k", "l", "a", "s", "d", "f", "g" }

---@type string[]
M.number_labels = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }

---@param number_of_labels integer
---@return string[]
function M.generate_label_strings(number_of_labels)
    local labels
    if config.options.labels_type == "home_row" then
        labels = vim.deepcopy(M.home_row_labels)
    elseif config.options.labels_type == "numbers" then
        labels = vim.deepcopy(M.number_labels)
    else
        labels = vim.deepcopy(config.options.custom_labels)
    end

    if number_of_labels > #labels then
        for _ = 1, number_of_labels - #labels do
            table.insert(labels, "*")
        end
    end

    return labels
end

---TODO: fine tune the position of the label window (take e.g. statusline into account)
---@param label string
---@param winnr_to_attach_to integer
function M.open_label_win(label, winnr_to_attach_to)
    local label_text = (" %s "):format(label)
    local bufnr = api.nvim_create_buf(false, true)
    local winnr = api.nvim_open_win(bufnr, false, {
        relative = "win",
        win = winnr_to_attach_to,
        anchor = "NW",
        row = 1,
        col = 1,
        width = #label_text,
        height = 1,
        style = "minimal",
        border = "none",
        noautocmd = true,
        focusable = false,
        zindex = 300, -- this should be higher than the zindex of any of the windows we are attaching to
    })

    if winnr == 0 then
        util.error("Failed to open window")
        return
    end

    M.active_labels[winnr_to_attach_to] = { label = label, winnr = winnr, bufnr = bufnr }

    api.nvim_buf_set_lines(bufnr, 0, 2, false, { label_text })

    local ns_id = api.nvim_create_namespace("wormhole")
    api.nvim_win_set_hl_ns(winnr, ns_id)
    api.nvim_set_hl(ns_id, "WormholeLabel", config.options.label_highlight)
    api.nvim_buf_add_highlight(bufnr, ns_id, "WormholeLabel", 0, 0, -1)
end

---@return integer winnr, integer bufnr
function M.create_dummy_buf()
    local bufnr = api.nvim_create_buf(false, true)
    local winnr = api.nvim_open_win(bufnr, true, {
        relative = "cursor",
        row = 0,
        col = 0,
        width = 1,
        height = 1,
        style = "minimal",
        border = "none",
        noautocmd = true,
        focusable = true,
    })

    if winnr == 0 then
        util.error("Failed to open dummy window")
        return -1, -1
    end

    return winnr, bufnr
end

function M.create_labels()
    local win_ids = api.nvim_tabpage_list_wins(0)
    -- filter out windows that are not focusable (since we can't jump to them)
    win_ids = vim.tbl_filter(function(w)
        local win_config = api.nvim_win_get_config(w)
        return win_config.focusable
    end, win_ids)

    local dummy_winnr, dummy_bufnr = M.create_dummy_buf()
    if dummy_winnr == -1 then
        util.error("Failed to create dummy buffer")
        return
    end

    local labels = M.generate_label_strings(#win_ids)
    for i, winnr in ipairs(win_ids) do
        M.open_label_win(labels[i], winnr)
        vim.keymap.set(
            "n",
            labels[i],
            vim.schedule_wrap(function()
                -- check if the window is still available
                if not api.nvim_win_is_valid(winnr) then
                    return
                end
                api.nvim_set_current_win(winnr)
                api.nvim_win_close(dummy_winnr, true)
                api.nvim_buf_delete(dummy_bufnr, { force = true })
                M.remove_labels()
            end),
            { silent = true, nowait = true, buffer = dummy_bufnr }
        )
    end
    vim.keymap.set(
        "n",
        "<Esc>",
        vim.schedule_wrap(function()
            api.nvim_win_close(dummy_winnr, true)
            api.nvim_buf_delete(dummy_bufnr, { force = true })
            M.remove_labels()
        end),
        { silent = true, nowait = true, buffer = dummy_bufnr }
    )
end

function M.remove_labels()
    for _, label in pairs(M.active_labels) do
        api.nvim_win_close(label.winnr, true)
        api.nvim_buf_delete(label.bufnr, { force = true })
    end
    M.active_labels = {}
end

return M
