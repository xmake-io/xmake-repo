package("postgresql")

    set_homepage("https://www.postgresql.org/")
    set_description("PostgreSQL Database Management System")

    on_fetch(function (package, opt)
        if opt.system then
            import("lib.detect.find_path")
            import("lib.detect.find_program")
            import("lib.detect.find_library")

            -- init search paths
            local paths = {}
            if package:is_plat("windows") then
                local regs = winos.registry_keys("HKEY_LOCAL_MACHINE\\SOFTWARE\\PostgreSQL\\Installations\\postgresql-x64-*")
                for _, reg in ipairs(regs) do
                    table.insert(paths, winos.registry_query(reg .. ";Base Directory"))
                end
            elseif package:is_plat("macosx") then
                for _, path in ipairs(os.dirs("/Library/PostgreSQL/*")) do
                    table.insert(paths, path)
                end
            elseif package:is_plat("linux") then
                for _, path in ipairs(os.dirs("/usr/lib/postgresql/*")) do
                    table.insert(paths, path)
                end
            end

            -- find programs
            local binfile = find_program("postgres", {paths = os.getenv("PATH")})
            if binfile then
                local packagedir = path.directory(path.directory(binfile))
                table.insert(paths, packagedir)
                package:addenv("PATH", path.join(packagedir, "bin"))
            end

            -- find library
            local result = {links = {}, linkdirs = {}, includedirs = {}, libfiles = {}}
            local libname = (package:is_plat("windows") and "libpq" or "pq")
            local linkinfo = find_library(libname, paths, {suffixes = "lib"})
            if linkinfo then
                table.insert(result.linkdirs, linkinfo.linkdir)
                table.insert(result.links, libname)
                if package:is_plat("windows") then
                    table.insert(result.libfiles, path.join(linkinfo.linkdir, "libpq.lib"))
                    table.insert(result.libfiles, path.join(linkinfo.linkdir, "libpq.dll"))
                end
            end

            -- find headers
            local path = find_path("libpq-fe.h", paths, {suffixes = "include"})
            if path then
                table.insert(result.includedirs, path)
            end
            path = find_path("postgres.h", paths, {suffixes = "include/server"})
            if path then
                table.insert(result.includedirs, path)
            end
            if #result.includedirs > 0 and #result.linkdirs > 0 then
                return result
            end
        end
    end)
