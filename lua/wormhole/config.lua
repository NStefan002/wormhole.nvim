local M = {}

---@type wormhole.config.full
M.defaults = {
    labels_type = "home_row",
    custom_labels = {},
    label_highlight = { link = "IncSearch" },
}

---@type wormhole.config.full
M.options = M.defaults

---@param opts? wormhole.config
function M.setup(opts)
    opts = opts or {}
    local ok, _ = M.validate_config(opts)
    if not ok then
        require("wormhole.util").error(
            "Invalid configuration for wormhole.nvim, run ':checkhealth wormhole' for more information."
        )
    end
    M.options = vim.tbl_deep_extend("force", M.defaults, opts)
end

---@param config wormhole.config
---@return boolean, string?
function M.validate_config(config)
    local util = require("wormhole.util")

    ---@type string[]
    local errors = {}
    local ok, err = util.validate({
        labels_type = { config.labels_type, "string", true },
        custom_labels = { config.custom_labels, "table", true },
        label_highlight = { config.label_highlight, "table", true },
    }, config, "wormhole.config")

    if not ok then
        table.insert(errors, err)
    end

    if #errors == 0 then
        return true, nil
    end
    return false, table.concat(errors, "\n")
end

return M
