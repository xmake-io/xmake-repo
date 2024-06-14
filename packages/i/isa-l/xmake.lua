package("isa-l")
    set_homepage("https://github.com/intel/isa-l")
    set_description("Intelligent Storage Acceleration Library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/intel/isa-l/archive/refs/tags/$(version).tar.gz",
             "https://github.com/intel/isa-l.git")

    add_versions("v2.31.0", "e218b7b2e241cfb8e8b68f54a6e5eed80968cc387c4b1af03708b54e9fb236f1")

    if not is_plat("windows", "mingw") then
        add_deps("autoconf", "automake", "libtool")
    end
    add_deps("nasm")

    on_install(function (package)
        if is_plat("windows") then
            local runenvs = import("package.tools.nmake").buildenvs(package)
            local nmake = import("lib.detect.find_tool")("nmake", {envs = runenvs})
            os.vrunv(nmake.program, {"/f", "Makefile.nmake"}, {envs = runenvs})
            os.vcp("isa-l.h", package:installdir("include/isa-l"))
            os.vcp("include/*.h", package:installdir("include/isa-l"))
            if package:config("shared") then
                os.vcp("isa-l.dll", package:installdir("bin"))
                os.vcp("isa-l.lib", package:installdir("lib"))
            else
                os.vcp("isa-l_static.lib", package:installdir("lib"))
            end
            if package:is_debug() then
                os.vcp("isa-l.pdb", package:installdir("bin"))
            end
        elseif is_plat("mingw") then
            os.cp(path.join(package:scriptdir(), "port", "isa-l.h.in"), "isa-l.h.in")
            os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
            import("package.tools.xmake").install(package, {version = package:version()})
        else
            local configs = {}
            table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
            if package:is_debug() then
                table.insert(configs, "--enable-debug")
            end
            import("package.tools.autoconf").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("crc16_t10dif", {includes = "isa-l/crc.h"}))
    end)
