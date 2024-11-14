function main(package, opt)
    if not opt.system then
        return
    end

    local java = package:find_tool("java", opt)
    if not java then return end

    if package:is_binary() then
        return true
    else
        if is_host("windows") then
            local sdkdir = os.getenv("JAVA_HOME")
            if not os.isdir(sdkdir) then
                return
            end

            local result = {}
            result.version = java.version
            result.includedirs = {path.join(sdkdir, "include"), path.join(sdkdir, "include", "win32")}
            result.linkdirs = path.join(sdkdir, "lib")
            result.links = {"jvm", "jawt"}
            package:addenv("PATH", path.join(sdkdir, "bin"), path.join(sdkdir, "bin", "server"))
            return result
        end
    end
end
