package("boostdep")
    set_kind("binary")
    set_homepage("https://boost.org/tools/boostdep")
    set_description("A tool to create Boost module dependency reports")
    set_license("BSL-1.0")

    add_urls("https://github.com/boostorg/boostdep.git")
    add_versions("2024.10.07", "289f2a16286e62348676f2abb75c0bd9968f156b")

    add_deps("boost", {configs = {filesystem = true}})

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("boost", {configs = {filesystem = true}})
            add_packages("boost")
            set_languages("c++17")
            target("boostdep")
                set_kind("binary")
                add_files("src/*.cpp")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        local boostdep = package:installdir("bin/boostdep")
        if is_host("windows") then
            boostdep = boostdep .. ".exe"
        end
        assert(os.isexec(boostdep), "boostdep not found!")
    end)
