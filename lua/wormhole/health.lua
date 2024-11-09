local M = {}

function M.check()
    local config = require("wormhole.config")
    vim.health.start("wormhole.nvim")
    local ok, err = config.validate_config(config.options)
    if ok then
        vim.health.ok("Setup is correct")
    else
        vim.health.error(("Setup is incorrect:\n%s"):format(err))
    end
end

return M
