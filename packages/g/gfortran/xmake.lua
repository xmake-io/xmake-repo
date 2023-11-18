package("gfortran")

    set_homepage("https://gcc.gnu.org/fortran/")
    set_description("The GNU Fortran compiler")

    on_fetch(function (package, opt)
        import("lib.detect.find_library")

        if opt.system then
            local fortran = package:find_tool("gfortran", opt)
            if not fortran then return end

            if package:is_binary() then
                return true
            else
                local installdir = path.directory(path.directory(fortran.program))
                local target
                local out, version = os.iorunv(fortran.program, {"-v", "-E"})
                if version then
                    target = version:match("Target: (.-)\n")
                    version = version:match("version (%d+%.%d+%.%d+)")
                    vmajor = version:split("%.")[1]

                    local paths = {
                        "/usr/lib",
                        "/usr/lib64",
                        "/usr/local/lib",
                        path.join(installdir, "lib"),
                    }
                    if target then
                        table.insert(paths, path.join("/usr/lib", target))
                        table.insert(paths, path.join("/usr/lib/gcc", target, vmajor))
                        table.insert(paths, path.join(installdir, "lib", target, vmajor))
                    end
                    local linkinfo = find_library("gfortran", paths)
                    if linkinfo then
                        return {
                            version = version,
                            links = "gfortran",
                            linkdirs = {linkinfo.linkdir},
                        }
                    end
                end
            end
        end
    end)
