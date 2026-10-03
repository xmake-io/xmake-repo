-- imports
import("test_addons")
import("test_templates")
import("test_packages")
import("check_versions")

-- get the arguments of the addon tests
--
-- @note we are called with the whole command line, but most of the options are only for
-- the package tests, e.g. `-a x86_64`, `--runtimes=MT`, so we must not pass them through
--
function _addon_argv(argv)
    local result = {}
    local with_addons = table.contains(argv, "--addon")
    local drop_value = false
    for _, arg in ipairs(argv) do
        if arg == "--addon" or arg == "-v" or arg == "--verbose" or arg == "-D" or arg == "--diagnosis"
            or arg == "-vD" or arg == "-Dv" then
            table.insert(result, arg)
            drop_value = false
        elseif arg:startswith("-") then
            -- an option of the package tests, it may take a value, e.g. `-a x86_64`
            drop_value = not arg:find("=", 1, true)
        elseif drop_value then
            drop_value = false
        elseif with_addons then
            -- the addon names, they are only given with `--addon`
            table.insert(result, arg)
        end
    end
    return result
end

function main(...)
    local argv = table.pack(...)
    local run_packages = false
    local run_templates = false
    local run_addons = false

    -- the new versions must be valid semantic versions, we check them first
    -- @see https://github.com/xmake-io/xmake/issues/7748
    check_versions()

    -- only test the addons? e.g. xmake l scripts/test.lua --addon esp32-devel
    if table.contains(argv, "--addon") then
        test_addons(table.unpack(_addon_argv(argv)))
        return
    end

    -- get modified files
    local diff = try {function () return os.iorun("git --no-pager diff --name-only HEAD^") end}
    if diff then
        for _, file in ipairs(diff:split("\n")) do
            file = file:trim()
            if file:startswith("packages") then
                run_packages = true
            elseif file:startswith("templates") then
                run_templates = true
            elseif file:startswith("addons") then
                run_addons = true
            end
        end
    else
        -- if git diff fails (e.g. not a git repo), default to running package tests
        run_packages = true
    end

    -- if no changes detected in packages, templates or addons, run package tests by default (e.g. tbox dev)
    if not run_packages and not run_templates and not run_addons then
        run_packages = true
    end

    -- run addon tests
    if run_addons then
        print("Running addon tests...")
        test_addons(table.unpack(_addon_argv(argv)))
    end

    -- run template tests
    if run_templates then
        print("Running template tests...")
        test_templates()
    end

    -- run package tests
    if run_packages then
        print("Running package tests...")
        test_packages(table.unpack(argv))
    end
end
