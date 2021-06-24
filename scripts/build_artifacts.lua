import("core.package.package")
import("core.base.semver")
import("packages")

function build_artifacts(name, versions)
    local buildinfo = {name = name, versions = versions}
    print(buildinfo)
    os.exec("git clone git@github.com:xmake-mirror/build-artifacts.git -b build")
    local oldir = os.cd("build-artifacts")
    local trycount = 0
    while trycount < 2 do
        local ok = try { function ()
            os.exec("git reset --hard HEAD^")
            os.exec("git pull origin build")
            io.save("build.txt", buildinfo)
            os.exec("git add -A")
            os.exec("git commit -a -m \"autobuild %s by xmake-repo/ci\"", name)
            os.exec("git push origin build")
            return true
        end }
        if ok then
            break
        end
        trycount = trycount + 1
    end
    assert(trycount < 2)
    os.cd(oldir)
end

function main()
    local files = os.iorun("git diff --name-only HEAD^")
    for _, file in ipairs(files:split('\n'), string.trim) do
       if file:find("packages", 1, true) and path.filename(file) == "xmake.lua" then
           assert(file == file:lower(), "%s must be lower case!", file)
           local packagedir = path.directory(file)
           local packagename = path.filename(packagedir)
           local instance = package.load_from_repository(packagename, nil, packagedir, file)
           if instance and packages.is_supported(instance, "windows")
              and (instance.is_headeronly and not instance:is_headeronly()) then
               local versions = instance:versions()
               if versions and #versions > 0 then
                   table.sort(versions, function (a, b) return semver.compare(a, b) > 0 end)
                   local version_latest = versions[1]
                   build_artifacts(instance:name(), table.wrap(version_latest))
               end
           end
       end
    end
end
