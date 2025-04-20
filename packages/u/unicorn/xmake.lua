package("unicorn")
    set_homepage("http://www.unicorn-engine.org")
    set_description("Unicorn CPU emulator framework (ARM, AArch64, M68K, Mips, Sparc, PowerPC, RiscV, S390x, TriCore, X86)")
    set_license("GPL-2.0")

    add_urls("https://github.com/unicorn-engine/unicorn/archive/refs/tags/$(version).tar.gz",
             "https://github.com/unicorn-engine/unicorn.git")

    add_versions("2.1.1", "8740b03053162c1ace651364c4c5e31859eeb6c522859aa00cb4c31fa9cbbed2")

    add_deps("cmake")
    add_deps("glib")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    add_configs("logging", {description = "Enable logging", default = false, type = "boolean"})
    add_configs("tracer", {description = "Trace unicorn execution", default = false, type = "boolean"})
    add_configs("archs", {description = "Enabled unicorn architectures", default = {"x86", "aarch64"}, type = "table"})

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "UNICORN_SHARED")
        end
    end)

    on_install("windows|!arm64", "macosx", "linux", "cross", function (package)
        io.replace("CMakeLists.txt", "if(UNICORN_INSTALL AND NOT MSVC)", "if(1)", {plain = true})

        local configs = {"-DUNICORN_BUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUNICORN_LOGGING=" .. (package:config("logging") and "ON" or "OFF"))
        table.insert(configs, "-DUNICORN_TRACER=" .. (package:config("tracer") and "ON" or "OFF"))

        local archs = table.concat(package:config("archs"), ";")
        table.insert(configs, "-DUNICORN_ARCH=" .. archs)
        import("package.tools.cmake").install(package, configs)

        if package:config("shared") then
            os.tryrm(package:installdir("lib/unicorn.lib"))
            os.rm(package:installdir("lib/*.a"))
        end

        if package:is_plat("windows") then
            if package:config("shared") then
                io.replace(package:installdir("include/unicorn/unicorn.h"), "__declspec(dllexport)", "__declspec(dllimport)", {plain = true})
            end
            if package:is_debug() then
                local dir = package:installdir(package:config("shared") and "bin" or "lib")
                os.trycp(path.join(package:buildir(), "unicorn.pdb"), dir)
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uc_open", {includes = "unicorn/unicorn.h"}))
    end)
