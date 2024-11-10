rockspec_format = "3.0"
package = "wormhole.nvim"
version = "scm-1"

local user = "NStefan002"

source = {
    url = "git+https://github.com/" .. user .. "/" .. package,
}
description = {
    homepage = "https://github.com/" .. user .. "/" .. package,
    labels = { "neovim", "neovim-plugin" },
    license = "MIT",
    summary = "Assign labels to windows and jump effortlessly with a single keypress.",
}
dependencies = {}
test_dependencies = {}
build = {
    type = "builtin",
    copy_directories = {
        "plugin",
    },
}
