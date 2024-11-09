local M = {}

---notify user of an error
---@param msg string
function M.error(msg)
    -- "\n" for nvim configs that don't use nvim-notify
    vim.notify("\n" .. msg, vim.log.levels.ERROR, { title = "Wormhole" })
end

---@param msg string
function M.info(msg)
    -- "\n" for nvim configs that don't use nvim-notify
    vim.notify("\n" .. msg, vim.log.levels.INFO, { title = "Wormhole" })
end

---@param opts table
---@param user_config table
---@param path string
---@return boolean, string?
function M.validate(opts, user_config, path)
    local ok, err = pcall(vim.validate, opts)
    if not ok then
        return false, string.format("%s: %s", path, err)
    end

    local errors = {}
    for key, _ in pairs(user_config) do
        if not opts[key] then
            table.insert(errors, string.format("'%s' is not a valid key of %s", key, path))
        end
    end

    if #errors == 0 then
        return true, nil
    end
    return false, table.concat(errors, "\n")
end

---@param t table Table to check
---@param value any Value to compare or predicate function reference
---@param f? fun(tx: any, v: any): boolean Function to compare values (fist argument is table value, second is value to compare)
---@return boolean `true` if `t` contains `value`
function M.tbl_contains(t, value, f)
    f = f or function(tx, v)
        return tx == v
    end
    for _, tx in pairs(t) do
        if f(tx, value) then
            return true
        end
    end
    return false
end

---@param map table<any, any>
---@return any[]
function M.get_map_keys(map)
    local keys = {}
    for k, _ in pairs(map) do
        table.insert(keys, k)
    end
    return keys
end

---@param elements string[]
---@param n integer number of variations to generate
---@return string[]
function M.generate_variations(elements, n)
    local variations = {}
    local function generate_variations_rec(prefix, len)
        if n == 0 then
            return
        end
        if len == 0 then
            table.insert(variations, prefix)
            n = n - 1
            return
        end
        for _, element in ipairs(elements) do
            generate_variations_rec(prefix .. element, len - 1)
        end
    end

    local len = 2
    while n > 0 do
        generate_variations_rec("", len)
        len = len + 1
    end

    return variations
end

return M
