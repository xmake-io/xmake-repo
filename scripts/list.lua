function main(...)
    local packages = {}
    for _, dir in ipairs(os.dirs(path.join("packages", "*", "*"))) do
        local package = path.filename(dir)
        local key = package:sub(1, 1)
        packages[key] = packages[key] or {}
        table.insert(packages[key], package)
    end
    print(packages)
end
