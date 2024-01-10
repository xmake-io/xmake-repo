function _check_version_from_github(package, url)
    -- TODO
    -- return version, shasum
end

function main(package)
    local checkers = {
        ["https://github%.com/.-/.-/archive/refs/tags/.*"] = _check_version_from_github,
        ["https://github%.com/.-/.-/releases/download/.*"] = _check_version_from_github
    }
    for _, url in ipairs(package:urls()) do
        for pattern, checker in pairs(checkers) do
            if url:match(pattern) then
                return checker(package, url)
            end
        end
    end
end
