package("boostdep")
    set_kind("binary")
    set_homepage("https://boost.org/tools/boostdep")
    set_description("A tool to create Boost module dependency reports")
    set_license("BSL-1.0")

    add_urls("https://github.com/boostorg/boostdep.git", {includes = "src"}) -- sparse checkout

    add_versions("2025.05.07", "de60ee6f8503c798e1d21aab8574c19b00062a7f")

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
        local boostdep = path.join(package:installdir(), "bin/boostdep")
        if is_host("windows") then
            boostdep = boostdep .. ".exe"
        end
        assert(os.isexec(boostdep), "boostdep not found!")
    end)
