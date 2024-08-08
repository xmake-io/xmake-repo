import("core.package.package")
import("core.base.semver")
import("core.base.hashset")
import("packages", {alias = "packages_util"})

-- load package
function _load_package(packagename, packagedir, packagefile)
    local funcinfo = debug.getinfo(package.load_from_repository)
    if funcinfo and funcinfo.nparams == 3 then -- >= 2.7.8
        return package.load_from_repository(packagename, packagedir, {packagefile = packagefile})
    else
        -- deprecated
        return package.load_from_repository(packagename, nil, packagedir, packagefile)
    end
end

function _need_artifact(instance)
    return (not instance:is_headeronly()) and (packages_util.is_supported(instance, "windows", "x64") or packages_util.is_supported(instance, "windows", "x86"))
end

function _build_artifacts(name, versions)
    local buildinfo = {name = name, versions = versions}
    print(buildinfo)
    os.tryrm("build-artifacts")
    os.exec("git clone git@github.com:xmake-mirror/build-artifacts.git -b build")
    local oldir = os.cd("build-artifacts")
    local trycount = 0
    while trycount < 2 do
        local ok = try
        {
            function ()
                io.save("build.txt", buildinfo)
                os.exec("git add -A")
                os.exec("git commit -a -m \"autobuild %s by xmake-repo/ci\"", name)
                os.exec("git push origin build")
                return true
            end,
            catch
            {
                function ()
                    os.exec("git reset --hard HEAD^")
                    os.exec("git pull origin build")
                end
            }
        }
        if ok then
            break
        end
        trycount = trycount + 1
    end
    assert(trycount < 2)
    os.cd(oldir)
end

function _get_latest_modified_packages()
    print("find latest modified packages ..")
    local instances = {}
    local files = os.iorun("git diff --name-only HEAD^")
    for _, file in ipairs(files:split('\n')) do
        file = file:trim()
        if file:find("packages", 1, true) and path.filename(file) == "xmake.lua" then
           assert(file == file:lower(), "%s must be lower case!", file)
           local packagedir = path.directory(file)
           local packagename = path.filename(packagedir)
           if #path.filename(path.directory(packagedir)) == 1 then
               local instance = _load_package(packagename, packagedir, file)
               if instance and _need_artifact(instance) then
                  table.insert(instances, instance)
                  print("  > %s", instance:name())
               end
            end
       end
    end
    print("%d found", #instances)
    return instances
end

function _get_all_packages()
    local packages = _g.packages
    if not packages then
        packages = {}
        for _, packagedir in ipairs(os.dirs(path.join("packages", "*", "*"))) do
            local packagename = path.filename(packagedir)
            local packagefile = path.join(packagedir, "xmake.lua")
            local instance = _load_package(packagename, packagedir, packagefile)
            local basename = instance:get("base")
            if instance and basename then
                local basedir = path.join("packages", basename:sub(1, 1):lower(), basename:lower())
                local basefile = path.join(basedir, "xmake.lua")
                instance._BASE = _load_package(basename, basedir, basefile)
            end
            if instance and _need_artifact(instance) then
                table.insert(packages, instance)
            end
        end
        _g.packages = packages
    end
    return packages
end

function _get_packagerefs_of(instance)
    local packagerefs = {}
    if instance:is_library() then
        local packages = _get_all_packages()
        for _, packageref in ipairs(packages) do
            local deps = packageref:get("deps")
            if deps and table.contains(table.wrap(deps), instance:name()) then
                table.insert(packagerefs, packageref)
            end
        end
    end
    return packagerefs
end

function _get_packagerefs_in_latest_24h()
    print("find packagerefs in latest 24h ..")
    local instances = {}
    local list = os.iorun("git log --since=\"24 hours ago\" --oneline")
    local lines = list:split('\n')
    if #lines > 0 then
        local line = lines[#lines]
        local commit = line:split(" ")[1]
        if commit and #commit == 8 then
            local files = os.iorun("git diff --name-only " .. commit .. "^")
            for _, file in ipairs(files:split('\n')) do
                file = file:trim()
                if file:find("packages", 1, true) and path.filename(file) == "xmake.lua" then
                   assert(file == file:lower(), "%s must be lower case!", file)
                   local packagedir = path.directory(file)
                   local packagename = path.filename(packagedir)
                   if #path.filename(path.directory(packagedir)) == 1 then
                       local instance = _load_package(packagename, packagedir, file)
                       if instance and _need_artifact(instance) then
                          table.insert(instances, instance)
                       end
                    end
               end
            end
        end
    end
    local packagerefs = hashset.new()
    for _, instance in ipairs(instances) do
        print("%s: ", instance:name())
        for _, packageref in ipairs(_get_packagerefs_of(instance)) do
            packagerefs:insert(packageref)
            print("  -> %s", packageref:name())
        end
    end
    local result = {}
    for _, packageref in packagerefs:keys() do
        if #result < 24 then
            table.insert(result, packageref)
        end
    end
    print("%d found", #result)
    return result
end

function main(updaterefs)
    local instances = updaterefs and _get_packagerefs_in_latest_24h() or _get_latest_modified_packages()
    for _, instance in ipairs(instances) do
       local versions = instance:versions()
       if versions and #versions > 0 then
           table.sort(versions, function (a, b) return semver.compare(a, b) > 0 end)
           local version_latest = versions[1]
           _build_artifacts(instance:name(), table.wrap(version_latest))
       end
    end
end
