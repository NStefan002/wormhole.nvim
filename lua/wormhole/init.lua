local M = {}

---@param opts wormhole.config
function M.setup(opts)
    require("wormhole.config").setup(opts)
end

return M
