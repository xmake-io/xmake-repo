package("hashcat")
    set_homepage("https://hashcat.net/hashcat/")
    set_description("World's fastest and most advanced password recovery utility.")
    set_license("MIT")

    set_urls("https://github.com/hashcat/hashcat/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hashcat/hashcat.git")
    add_versions("v7.1.2", "9546a6326d747530b44fcc079babad40304a87f32d3c9080016d58b39cfc8b96")

    -- if shared=false is specified, the library will not be built.
    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    add_configs("frontend", {description = "Build the hashcat frontend executable.", default = true, type = "boolean"})
    add_configs("bridge", {description = "Build the cross-language bridges.", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread", "dl", "rt", "m")
    elseif is_plat("bsd") then
        add_syslinks("pthread", "m")
    elseif is_plat("macosx") then
        add_syslinks("pthread", "IOReport")
        add_frameworks("CoreFoundation", "CoreGraphics", "Foundation", "IOKit", "Metal")
    elseif is_plat("cygwin") then
        add_syslinks("psapi")
    elseif is_plat("msys") then
        add_syslinks("psapi", "ws2_32", "powrprof")
    end

    add_deps("python >=3.12")
    add_deps("lzma", "zlib", "opencl-headers", "xxhash", "minizip", "libiconv")
    on_load(function (package)
        package:add("includedirs", "include", "include/OpenCL")
    end)

    -- unsupported mingw on macosx: gendef tool is missing.
    on_install("linux", "bsd", "macosx", "msys", "mingw@windows,linux", "cygwin", function (package)
        import("package.tools.make")

        local configs = {
            "PRODUCTION=1",
            "USE_SYSTEM_LZMA=1",
            "USE_SYSTEM_ZLIB=1",
            "USE_SYSTEM_OPENCL=1",
            "USE_SYSTEM_XXHASH=1"
        }

        table.insert(configs, "DEBUG=" .. (package:is_debug() and "1" or "0"))
        table.insert(configs, "SHARED=" .. (package:config("shared") and "1" or "0"))
        table.insert(configs, "PREFIX=" .. package:installdir():gsub("\\", "/"))

        local envs = make.buildenvs(package)

        local cflags = {}
        local ldflags = {}
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(cflags, "-I" .. includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(ldflags, "-L" .. linkdir)
                end
            end
        end
        table.insert(ldflags, "-liconv")

        envs.CFLAGS = envs.CFLAGS .. " " .. table.concat(cflags, " ")
        envs.LDFLAGS = envs.LDFLAGS .. " " .. table.concat(ldflags, " ")

        if not package:config("frontend") then
            io.replace("src/Makefile", "default: $(HASHCAT_FRONTEND)", "default: $(HASHCAT_LIBRARY)", {plain = true})
            io.replace("src/Makefile", "install_bridges install_hashcat", "install_bridges", {plain = true})
        end

        io.replace("src/Makefile", "-llzmasdk", "-llzma", {plain = true})
        io.replace("src/Makefile", "install: install_docs", "install: ", {plain = true})
        io.replace("src/Makefile", ".$(VERSION_PURE)", "", {plain = true})

        if package:is_plat("macosx") and not package:is_arch("x86_64") then
            io.replace("src/Makefile", "CFLAGS_NATIVE           += -arch x86_64", "", {plain = true})
            io.replace("src/Makefile", "LFLAGS_NATIVE           += -arch x86_64", "", {plain = true})
        end

        if not package:config("bridge") then
            io.replace("src/Makefile", "modules bridges", "modules", {plain = true})
            io.replace("src/Makefile", "modules_linux bridges_linux", "modules_linux", {plain = true})
            io.replace("src/Makefile", "modules_win bridges_win", "modules_win", {plain = true})
            io.replace("src/Makefile", "install_modules install_bridges", "install_modules", {plain = true})
            io.replace("src/Makefile", "include $(wildcard src/bridges/bridge_*.mk)", "", {plain = true})
        end

        -- sometimes hashcat will misjudge the platform.
        if package:is_plat("msys", "mingw") then
            table.insert(configs, "UNAME=MSYS2")
            table.insert(configs, "CC=" .. package:build_getenv("cc"))
            table.insert(configs, "CXX=" .. package:build_getenv("cxx"))
            table.insert(configs, "AR=" .. package:build_getenv("ar"))
        end

        make.build(package, configs, {envs = envs})

        if package:is_plat("msys", "mingw", "cygwin") then
            -- enable installation in msys, since we defined PREFIX.
            io.replace("src/Makefile", "$(error $(ERROR_INSTALL_DISALLOWED))", "", {plain = true})
        end

        table.insert(configs, "install")
        make.make(package, configs, {envs = envs})

        os.cp("OpenCL", package:installdir("include"))

        -- fix hashcat import library on msys.
        if package:is_plat("msys", "mingw", "cygwin") then
            os.cd(package:installdir("lib"))
            os.vrun("gendef hashcat.dll")
            os.vrun("dlltool -d hashcat.def -l libhashcat.a -D hashcat.dll")
            os.mv("hashcat.dll", "../bin")
        end
    end)

    on_test(function (package)
        if package:config("frontend") then
            local prefix = is_host("windows") and ".exe" or ""
            assert(os.isexec(package:installdir("bin/hashcat" .. prefix)), "hashcat executable not found!")
        end
        assert(package:has_cfuncs("hashcat_init", {includes = {"hashcat/types.h", "hashcat/hashcat.h"}}))
    end)
