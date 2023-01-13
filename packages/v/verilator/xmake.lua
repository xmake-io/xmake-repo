package("verilator")
    set_kind("toolchain")
    set_homepage("https://verilator.org")
    set_description("Verilator open-source SystemVerilog simulator and lint system")

--    add_urls("https://github.com/verilator/verilator/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/verilator/verilator.git")
    add_versions("2023.1.10", "5fce23e90d2a721bb712dc9aacde594558489dda")

    -- wait for next release with cmake
--    add_versions("v5.004", "7d193a09eebefdbec8defaabfc125663f10cf6ab0963ccbefdfe704a8a4784d2")

    if is_plat("windows") then
        add_deps("winflexbison", {kind = "library"})
    else
        add_deps("flex", {kind = "library"})
        add_deps("bison")
    end
    add_deps("python 3.x", {kind = "binary"})

    if is_plat("windows") then
        add_deps("cmake")
    else
        add_deps("autoconf", "automake", "libtool")
    end

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
        envs.WIN_FLEX_BISON = winflexbison:installdir()
        io.replace("src/CMakeLists.txt", '${ASTGEN} -I"${srcdir}"', '${ASTGEN} -I "${srcdir}"', {plain = true})
        cmake.install(package, configs, {envs = envs, cxflags = cxflags, buildir = "build"})
        print(os.files("build/**"))
        print(os.files(path.join(package:installdir(), "**")))
    end)

    on_install("linux", "macosx", function (package)
        local configs = {}
        local cxflags = {}
        local flex = package:dep("flex"):fetch()
        if flex then
            local includedirs = flex.sysincludedirs or flex.includedirs
            for _, includedir in ipairs(includedirs) do
                table.insert(cxflags, "-I" .. includedir)
            end
        end
        os.vrun("autoconf")
        import("package.tools.autoconf").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        os.vrun("verilator --version")
    end)
