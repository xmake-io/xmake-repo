import("lib.detect.find_tool")

function main(package, opt)
    if not opt.system then
        return
    end

    local paths = {}
    if is_host("linux") then
        for _, ver in ipairs({"8", "11", "17", "21"}) do
            local dir = format("/usr/lib/jvm/java-%s-openjdk-amd64", ver)
            if os.isdir(dir) then
                table.insert(paths, dir)
            end
        end
    end

    opt.version = true
    opt.paths = table.join2(table.wrap(opt.paths), paths)

    local java = find_tool("java", opt)
    if not java then
        return
    end

    local result = {}
    result.version = java.version

    if package:is_binary() then
        return result
    end

    if is_host("windows") then
        local sdkdir = os.getenv("JAVA_HOME")
        if not os.isdir(sdkdir) then
            return
        end

        result.includedirs = {path.join(sdkdir, "include"), path.join(sdkdir, "include/win32")}
        result.linkdirs = path.join(sdkdir, "lib")
        result.links = {"jvm", "jawt"}
        result.bindirs = {path.join(sdkdir, "bin"), path.join(sdkdir, "bin/server")}
        package:addenv("PATH", result.bindirs)
        return result
    elseif is_host("linux") then
        local sdkdir = paths[1]
        if not sdkdir then
            return
        end

        result.includedirs = {path.join(sdkdir, "include"), path.join(sdkdir, "include/linux")}
        result.linkdirs = {path.join(sdkdir, "lib"), path.join(sdkdir, "lib/server")}
        result.links = {"java", "jli", "jvm"}
        result.bindirs = path.join(sdkdir, "bin")
        package:addenv("LD_LIBRARY_PATH", result.linkdirs)
        return result
    elseif is_host("macosx") then
    end
end
