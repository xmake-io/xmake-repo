package("libxnvctrl")

    set_homepage("https://www.nvidia.com/en-us/drivers/unix/")
    set_description("NVIDIA driver control panel")

    if is_plat("linux") then
        add_extsources("apt::libxnvctrl-dev", "pacman::libxnctrl")
    end

    on_fetch("linux", function (package, opt)
        if opt.system then
            import("lib.detect.find_path")
            import("lib.detect.find_library")

            -- init search paths
            local paths = {"/usr"}

            -- find library
            local result = {links = {}, linkdirs = {}, includedirs = {}}
            local arch = package:is_arch("x86_64") and "x86_64" or "x86"
            local archsuffix = arch .. "-linux-gnu"
            local linkinfo = find_library("XNVCtrl", paths, {suffixes = {"lib", path.join("lib", archsuffix)}})
            if linkinfo then
                table.insert(result.linkdirs, linkinfo.linkdir)
                table.insert(result.links, "XNVCtrl")
            end
            result.linkdirs = table.unique(result.linkdirs)

            -- find headers
            local path = find_path("NVCtrl/NVCtrl.h", paths, {suffixes = "include"})
            if path then
                table.insert(result.includedirs, path)
            end
            if #result.includedirs > 0 and #result.linkdirs > 0 then
                return result
            end
        end
    end)
