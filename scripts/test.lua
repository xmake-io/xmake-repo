function main(...)
    local packages = {...}
    if #packages == 0 then
        local files = os.iorun("git diff --name-only HEAD^")
        for _, file in ipairs(files:split('\n'), string.trim) do
            if file:find("packages", 1, true) and path.filename(file) == "xmake.lua" then
                local package = path.filename(path.directory(file))
                table.insert(packages, package)
            end
        end
        table.insert(packages, "tbox")
    end
    if #packages > 0 then
        local workdir = path.join(os.tmpdir(), "xmake-repo")
        print(packages)
        os.tryrm(workdir)
        os.mkdir(workdir)
        os.cd(workdir)
        os.exec("xmake create test")
        os.cd("test")
        os.exec("xmake require -f -v -y %s", table.concat(packages, " "))
    end
end
