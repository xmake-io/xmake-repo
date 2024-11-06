package("verilator")
    set_kind("toolchain")
    set_homepage("https://verilator.org")
    set_description("Verilator open-source SystemVerilog simulator and lint system")

    add_urls("https://github.com/verilator/verilator/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/verilator/verilator.git")

    add_versions("v5.028", "02d4b6f34754b46a97cfd70f5fcbc9b730bd1f0a24c3fc37223397778fcb142c")
    add_versions("v5.016", "66fc36f65033e5ec904481dd3d0df56500e90c0bfca23b2ae21b4a8d39e05ef1")

    on_load(function (package)
        if not package:is_precompiled() then
            if package:is_plat("windows") then
                package:add("deps", "cmake")
                package:add("deps", "winflexbison", {kind = "library"})
            else
                package:add("deps", "flex", {kind = "library"})
                package:add("deps", "bison")
                package:add("deps", "autoconf", "automake", "libtool")
            end
            package:add("deps", "python 3.x", {kind = "binary"})
        end
        if package:version() and package:version():lt("5.028") then
            package:mark_as_pathenv("VERILATOR_ROOT")
            package:addenv("VERILATOR_ROOT", ".")
        end
    end)

    on_install("windows", function (package)
        import("package.tools.cmake")
        local configs = {}
        local cxflags = {}
        local winflexbison = package:dep("winflexbison")
        local flex = winflexbison:fetch()
        if flex then
            local includedirs = flex.sysincludedirs or flex.includedirs
            for _, includedir in ipairs(includedirs) do
                table.insert(cxflags, "-I" .. includedir)
            end
        end
        local envs = cmake.buildenvs(package)
        envs.VERILATOR_ROOT = nil
        envs.WIN_FLEX_BISON = winflexbison:installdir()
        io.replace("src/CMakeLists.txt", '${ASTGEN} -I"${srcdir}"', '${ASTGEN} -I "${srcdir}"', {plain = true})
        cmake.install(package, configs, {envs = envs, cxflags = cxflags})
        os.cp(path.join(package:installdir("bin"), "verilator_bin.exe"), path.join(package:installdir("bin"), "verilator.exe"))
    end)

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf")
        local configs = {}
        local cxflags = {}
        local flex = package:dep("flex"):fetch()
        if flex then
            local includedirs = flex.sysincludedirs or flex.includedirs
            for _, includedir in ipairs(includedirs) do
                table.insert(cxflags, "-I" .. includedir)
            end
        end
        io.replace("Makefile.in", "$(VL_INST_MAN_FILES)", "", {plain = true})
        os.vrun("autoconf")
        local envs = autoconf.buildenvs(package, {cxflags = cxflags})
        envs.VERILATOR_ROOT = nil
        local jobs
        if package:version() and package:version():ge("5.028") then
            jobs = 1
        end
        autoconf.install(package, configs, {envs = envs, jobs = jobs})
    end)

    on_test(function (package)
        os.vrun("verilator --version")
    end)
