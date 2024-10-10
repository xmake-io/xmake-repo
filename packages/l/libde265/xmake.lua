package("libde265")
    set_homepage("https://www.libde265.org/")
    set_description("Open h.265 video codec implementation.")
    set_license("LGPL-3.0")

    add_urls("https://github.com/strukturag/libde265/releases/download/v$(version)/libde265-$(version).tar.gz",
             "https://github.com/strukturag/libde265.git")

    add_versions("1.0.15", "00251986c29d34d3af7117ed05874950c875dd9292d016be29d3b3762666511d")
    add_versions("1.0.8", "24c791dd334fa521762320ff54f0febfd3c09fc978880a8c5fbc40a88f21d905")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "LIBDE265_STATIC_BUILD")
        end
    end)

    on_install(function (package)
        local configs = {"-DENABLE_SDL=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DDISABLE_SSE=" .. (package:is_arch("x86", "x64", "x86_64") and "OFF" or "ON"))
        table.insert(configs, "-DENABLE_ENCODER=" .. (package:config("tools") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_DECODER=" .. (package:config("tools") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=''")
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "libde265/**.pdb"), dir)
            if package:config("tools") then
                os.vcp(path.join(package:buildir(), "enc265/*.pdb"), package:installdir("bin"))
                os.vcp(path.join(package:buildir(), "dec265/*.pdb"), package:installdir("bin"))
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("de265_new_decoder", {includes = "libde265/de265.h"}))
    end)
