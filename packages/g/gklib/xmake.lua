package("gklib")
    set_homepage("https://github.com/KarypisLab/GKlib")
    set_description("A library of various helper routines and frameworks used by many of the lab's software")
    set_license("Apache-2.0")

    add_urls("https://github.com/KarypisLab/GKlib.git")
    add_versions("2023.03.26", "8bd6bad750b2b0d90800c632cf18e8ee93ad72d7")

    add_configs("regex", {description = "Enable GKREGEX support", default = false, type = "boolean"})
    add_configs("rand", {description = "Enable GKRAND support", default = false, type = "boolean"})
    add_configs("openmp", {description = "Enable openmp", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    elseif is_plat("windows") then
        add_defines("USE_GKREGEX", "__thread=__declspec(thread)")
    elseif is_plat("mingw") then
        add_defines("USE_GKREGEX")
    end

    on_install("!iphoneos", function (package)
        local configs = {
            openmp = package:config("openmp"),
            regex = package:config("regex"),
            rand = package:config("rand")
        }

        if configs.regex then
            package:add("defines", "USE_GKREGEX")
        end

        io.replace("gk_arch.h", "gk_ms_stdint.h", "stdint.h", {plain = true})
        io.replace("gk_arch.h", "gk_ms_inttypes.h", "inttypes.h", {plain = true})

        io.replace("gk_arch.h", "LINUX", "__linux__", {plain = true})
        for _, file in ipairs({"timers.c", "gk_arch.h", "error.c", "string.c"}) do
            io.replace(file, "WIN32", "_WIN32", {plain = true})
        end

        if configs.openmp then
            for _, file in ipairs({"GKlib.h", "timers.c", "gk_proto.h"}) do
                io.replace(file, "__OPENMP__", "_OPENMP", {plain = true})
            end
        end
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gk_strstr_replace", {includes = "GKlib.h"}))
    end)
