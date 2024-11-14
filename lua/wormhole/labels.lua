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
M.number_labels = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

---@type { winnr: integer, bufnr: integer }
M.dummy_buf = {}

---@type boolean
M.closing = false

---@param number_of_labels integer
---@return string[]
function M.generate_label_strings(number_of_labels)
    local labels
    if config.options.labels_type == "home_row" then
        labels = vim.deepcopy(M.home_row_labels)
    elseif config.options.labels_type == "numbers" then
        labels = vim.deepcopy(M.number_labels)
    elseif #config.options.custom_labels == 0 then
        -- if the labels_type is custom, but no custom labels are provided, we fall back to home_row
        labels = vim.deepcopy(M.home_row_labels)
    else
        labels = vim.deepcopy(config.options.custom_labels)
    end

    if number_of_labels > #labels then
        util.generate_variations(labels, number_of_labels - #labels)
    end

    return labels
end

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
        col = 2,
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
        M.dummy_buf = { winnr = -1, bufnr = -1 }
        return
    end

    M.dummy_buf = { winnr = winnr, bufnr = bufnr }
end

function M.close_dummy_buf()
    vim.schedule(function()
        if not api.nvim_win_is_valid(M.dummy_buf.winnr) then
            return
        end
        api.nvim_win_close(M.dummy_buf.winnr, true)
        api.nvim_buf_delete(M.dummy_buf.bufnr, { force = true })
        M.dummy_buf = { winnr = -1, bufnr = -1 }
    end)
end

function M.create_labels()
    if M.closing then
        return
    end

    local win_ids = api.nvim_tabpage_list_wins(0)
    -- filter out windows that are not focusable (since we can't jump to them)
    win_ids = vim.tbl_filter(function(w)
        local win_config = api.nvim_win_get_config(w)
        return win_config.focusable
    end, win_ids)

    M.create_dummy_buf()
    if not api.nvim_win_is_valid(M.dummy_buf.winnr) then
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
                api.nvim_win_close(M.dummy_buf.winnr, true)
                api.nvim_buf_delete(M.dummy_buf.bufnr, { force = true })
                M.remove_labels()
            end),
            { silent = true, nowait = true, buffer = M.dummy_buf.bufnr }
        )
    end
end

function M.remove_labels()
    M.closing = true
    vim.schedule(function()
        for _, label in pairs(M.active_labels) do
            api.nvim_win_close(label.winnr, true)
            api.nvim_buf_delete(label.bufnr, { force = true })
        end
        M.active_labels = {}
        M.closing = false
    end)
end

function M.toggle_labels()
    if vim.tbl_isempty(M.active_labels) then
        M.create_labels()
    else
        M.close_dummy_buf()
        M.remove_labels()
    end
end

return M
