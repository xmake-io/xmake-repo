-- imports
import("test_templates")
import("test_packages")

function main(...)
    local argv = table.pack(...)
    local run_packages = false
    local run_templates = false

    -- get modified files
    local diff = try {function () return os.iorun("git --no-pager diff --name-only HEAD^") end}
    if diff then
        for _, file in ipairs(diff:split("\n")) do
            local file = file:trim()
            if file:startswith("packages") then
                run_packages = true
            elseif file:startswith("templates") then
                run_templates = true
            end
        end
    else
        -- if git diff fails (e.g. not a git repo), default to running package tests
        run_packages = true
    end

    -- if no changes detected in packages or templates, run package tests by default (e.g. tbox dev)
    if not run_packages and not run_templates then
        run_packages = true
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
