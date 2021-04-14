package("houdini")

    set_homepage("https://www.sidefx.com/")
    set_description("Houdini is built from the ground up to be a procedural system that empowers artists to work freely, create multiple iterations and rapidly share workflows with colleagues.")

    on_fetch(function (package, opt)
        if opt.system then
            import("lib.detect.find_path")
            import("lib.detect.find_program")
            import("lib.detect.find_library")

            -- init search paths
            local paths = {"$(env Houdini_ROOT)"}
            if package:is_plat("windows") then
                local keys = winos.registry_keys("HKEY_LOCAL_MACHINE\\SOFTWARE\\Side Effects Software\\Houdini *.*.*")
                for _, key in ipairs(keys) do
                    table.insert(paths, winos.registry_query(key .. ";InstallPath"))
                end
            elseif package:is_plat("macosx") then
                for _, path in ipairs(os.dirs("/Applications/Houdini/Houdini*.*.*")) do
                    table.insert(paths, path)
                end
            else
                for _, path in ipairs(os.dirs("/opt/hfs*.*.*")) do
                    table.insert(paths, path)
                end
            end

            -- find sdkdir
            local result = {sdkdir = nil, links = {}, linkdirs = {}, includedirs = {}, libfiles = {}}
            result.sdkdir = find_path("houdini_setup", paths)
            if result.sdkdir then
                package:addenv("PATH", path.join(result.sdkdir, "bin"))
            else
                local prog = find_program("houdini", {paths = os.getenv("PATH")})
                if prog then
                    result.sdkdir = path.directory(path.directory(prog))
                else
                    return
                end
            end
            
            -- find library
            local prefix = (package:is_plat("windows") and "lib" or "")
            local libs = {"HAPI"}
            for _, lib in ipairs(libs) do
                local libname = prefix .. lib
                local linkinfo = find_library(libname, {result.sdkdir}, {suffixes = "custom/houdini/dsolib"})
                if linkinfo then
                    table.insert(result.linkdirs, linkinfo.linkdir)
                    table.insert(result.links, libname)
                    if package:is_plat("windows") then
                        table.insert(result.libfiles, path.join(linkinfo.linkdir, libname .. ".lib"))
                        table.insert(result.libfiles, path.join(result.sdkdir, "bin", libname .. ".dll"))
                    end
                end
            end

            -- find headers
            local path = find_path(path.join("HAPI", "HAPI.h"), {result.sdkdir}, {suffixes = path.join("toolkit", "include")})
            if path then
                table.insert(result.includedirs, path)
            end

            if #result.includedirs > 0 and #result.linkdirs > 0 then
                return result
            end
        end
    end)
