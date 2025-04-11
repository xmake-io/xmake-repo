package("sokol-tools")
    set_kind("binary")
    set_homepage("https://github.com/floooh/sokol-tools")
    set_description("Command line tools for use with sokol headers")
    set_license("MIT")

    add_urls("https://github.com/floooh/sokol-tools.git")
    add_versions("2025.02.10", "227e74250e853c0e02e8c77accbe8b31111410be")

    add_resources(">=2025.02", "fips", "https://github.com/floooh/fips.git", "3fb2f75b8735552c4aae96d4c83d9aa18e6a2800")

    add_deps("cmake")

    on_load(function (package)
        if not package:is_precompiled() then
            package:add("deps", "python 3.x")
        end
    end)

    on_install("@macosx", "@linux", "@windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        local fipsdir = package:resourcefile("fips")
        if os.isdir("sokol-tools") then
            os.tryrm("./fips-deploy")
            os.tryrm("./fips")
            os.cd("sokol-tools")
            package:set("sourcedir", "sokol-tools")
        end
        if fipsdir then
            os.cp(fipsdir, "../fips")
        end
        if package:is_plat("linux") then
            io.replace("src/shdc/CMakeLists.txt", "-static", "", {plain = true})
        elseif package:is_plat("windows") then
            io.replace("../fips/cmake-toolchains/windows.cmake", "/WX", "", {plain = true})
        end
        import("package.tools.cmake").build(package, configs)
        os.cp("../fips-deploy/sokol-tools/*", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("sokol-shdc -h")
    end)
