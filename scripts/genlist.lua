import("packages", {alias = "get_packages"})

function main(...)
    
    -- get packages
    local packages = get_packages({onlyhost = true})
    local tables = {}
    local col = 1
    local row_max = 0
    for _, pkgs in pairs(packages) do
        for row, pkg in ipairs(pkgs) do
            tables[row] = tables[row] or {}
            tables[row][col] = pkg
        end
        if #pkgs > row_max then
            row_max = #pkgs
        end
        col = col + 1
    end

    -- generate markdown table
    local packages_md = "## All Supported Packages\n\n"
    for plat, _ in pairs(packages) do
        packages_md = packages_md .. "|" .. plat
    end
    packages_md = packages_md .. "|\n"
    for plat, _ in pairs(packages) do
        packages_md = packages_md .. "|" .. (plat:gsub('.', '-')) 
    end
    packages_md = packages_md .. "|\n"
    for y = 1, row_max do
        for x = 1, col do
            local pkg = tables[y][x]
            local info = ""
            if pkg then
                if pkg.generic then
                    info = pkg.name
                else
                    info = pkg.name .. "(" .. table.concat(pkg.archs, ",") .. ")"
                end
            end
            packages_md = packages_md .. "|" .. info 
        end
        packages_md = packages_md .. "|\n"
    end
    print(packages_md)
    io.writefile(path.join(os.scriptdir(), "..", "PKGLIST.md"), packages_md)
end
