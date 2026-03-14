-- imports

function _check_directory_names(file)
    local relative_path = path.relative(file, "templates")
    local parts = relative_path:split("[/\\]")

    -- check directory names (must be lowercase)
    for _, part in ipairs(parts) do
        assert(part == part:lower(), "Error: template path component '" .. part .. "' in '" .. file .. "' must be lowercase!")
    end
end

function _check_target_name(file, content)
    assert(content:find('target%("%${TARGET_NAME}"%)'), "Error: " .. file .. " must use target(\"${TARGET_NAME}\")!")
end

function _check_faq(file, content)
    assert(content:find("%${FAQ}"), "Error: " .. file .. " must include ${FAQ}!")
end

function _check_mode_rules(file, content)
    assert(content:find('add_rules%("mode.debug", "mode.release"%)'), "Error: " .. file .. " must include add_rules(\"mode.debug\", \"mode.release\")!")
end

function main(...)

    -- scan modified templates
    local templates = {}
    local diff = try {function () return os.iorun("git --no-pager diff --name-only HEAD^") end}
    if diff then
        for _, file in ipairs(diff:split("\n")) do
            file = file:trim()
            if file:startswith("templates") and file:endswith("xmake.lua") then
                table.insert(templates, file)
            end
        end
    end

    if #templates == 0 then
        return
    end

    print("checking templates ...")
    for _, file in ipairs(templates) do
        if os.isfile(file) then
            print("  > " .. file)
            local content = io.readfile(file)
            _check_directory_names(file)
            _check_target_name(file, content)
            _check_faq(file, content)
            _check_mode_rules(file, content)
        end
    end
    print("All templates passed!")
end

return main
