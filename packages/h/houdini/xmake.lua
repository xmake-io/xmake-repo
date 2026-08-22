package("houdini")

    set_homepage("https://www.sidefx.com/")
    set_description("Houdini is built from the ground up to be a procedural system that empowers artists to work freely, create multiple iterations and rapidly share workflows with colleagues.")

    add_configs("utils", {description = "Enabled Houdini utilities.", default = {}, type = "table"})

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
                try { function ()
                    local values = winos.registry_values("HKEY_LOCAL_MACHINE\\Software\\Side Effects Software\\Houdini")
                    for _, value in ipairs(values) do
                        if not value:find("LicenseServer") then
                            table.insert(paths, winos.registry_query(value))
                        end
                    end
                end }
                for _, path in ipairs(os.dirs("%PROGRAMFILES%\\Side Effects Software\\Houdini *.*.*")) do
                    table.insert(paths, path)
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
            vprint("Searching for Houdini SDK...", paths)
            local result = {sdkdir = nil, links = {}, linkdirs = {}, includedirs = {}, libfiles = {}}
            result.sdkdir = find_path("houdini_setup", paths)
            if result.sdkdir then
                package:addenv("PATH", path.join(result.sdkdir, "bin"))
            else
                local prog = find_program("houdini", {paths = os.getenv("PATH")})
                if prog then
                    result.sdkdir = path.directory(path.directory(prog))
                    package:addenv("PATH", path.join(result.sdkdir, "bin"))
                else
                    return
                end
            end
            
            -- find library
            local pkg_utils = package:config("utils") or {}
            local default_utils = {package:is_plat("windows") and "libHAPI" or "HAPI"}
            local libs = table.join(default_utils, pkg_utils)
            if package:is_plat("windows") then
                for _, lib in ipairs(pkg_utils) do
                    table.insert(libs, "lib" .. lib)
                end
            end
            for _, lib in ipairs(libs) do
                local libname = lib
                local linkinfo = find_library(libname, {result.sdkdir}, {suffixes = "custom/houdini/dsolib"})
                if linkinfo then
                    table.insert(result.linkdirs, linkinfo.linkdir)
                    table.insert(result.links, libname)
                    if package:is_plat("windows") then
                        table.insert(result.libfiles, path.join(linkinfo.linkdir, libname .. ".lib"))
                        for _, libpath in ipairs(os.files(path.join(result.sdkdir, "bin", libname .. "*.dll"))) do
                            if libpath:find(libname .. "[%-%d]*%.dll") then
                                table.insert(result.libfiles, libpath)
                            end
                        end
                    end
                end
            end

            -- find headers
            local includepath = find_path(path.join("HAPI", "HAPI.h"), {result.sdkdir}, {suffixes = path.join("toolkit", "include")})
            if includepath then
                table.insert(result.includedirs, includepath)
            end

            -- find version
            local versionfile = path.join(result.sdkdir, "toolkit", "cmake", "HoudiniConfigVersion.cmake")
            if os.isfile(versionfile) then
                for line in io.lines(versionfile) do
                    local version = line:match('set%( PACKAGE_VERSION (.-) %)')
                    if version then
                        result.version = version
                        break
                    end
                end
            end

            if #result.includedirs > 0 and #result.linkdirs > 0 then
                return result
            end
        end
    end)
