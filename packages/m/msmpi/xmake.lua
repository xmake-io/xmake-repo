package("msmpi")

    set_homepage("https://docs.microsoft.com/en-us/message-passing-interface/microsoft-mpi")
    set_description("Microsoft MPI (MS-MPI) is a Microsoft implementation of the Message Passing Interface standard for developing and running parallel applications on the Windows platform.")

    on_fetch("windows", function (package, opt)
        if opt.system then
            import("lib.detect.find_path")
            import("lib.detect.find_library")

            -- init search paths
            local paths = {
                "$(env MSMPI_ROOT)",
                "$(env MSMPI_INC)\\..",
                "$(env PROGRAMFILES%(x86%))\\Microsoft SDKs\\MPI"
            }

            -- find library
            local result = {links = {}, linkdirs = {}, includedirs = {}}
            local arch = package:is_arch("x64") and "x64" or "x86"
            for _, lib in ipairs({"msmpi", "msmpifec", "msmpifmc"}) do
                local linkinfo = find_library(lib, paths, {suffixes = path.join("Lib", arch)})
                if linkinfo then
                    table.insert(result.linkdirs, linkinfo.linkdir)
                    table.insert(result.links, lib)
                end
            end
            result.linkdirs = table.unique(result.linkdirs)

            -- find headers
            local path = find_path("mpi.h", paths, {suffixes = "Include"})
            if path then
                table.insert(result.includedirs, path)
            end
            if #result.includedirs > 0 and #result.linkdirs > 0 then
                return result
            end
        end
    end)
