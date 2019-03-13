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
    end
    if #packages == 0 then
        table.insert(packages, "\"tbox dev\"")
    end
    local repodir = os.curdir()
    local workdir = path.join(os.tmpdir(), "xmake-repo")
    print(packages)
    os.setenv("XMAKE_STATS", "false")
    os.tryrm(workdir)
    os.mkdir(workdir)
    os.cd(workdir)
    os.exec("xmake create test")
    os.cd("test")
    os.exec("xmake repo --add local-repo %s", repodir)
    os.exec("xmake repo -l")
    os.exec("xmake require -f -v -D -y %s", table.concat(packages, " "))
end
