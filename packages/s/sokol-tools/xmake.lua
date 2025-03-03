package("sokol-tools")
    set_kind("binary")
    set_homepage("https://github.com/floooh/sokol-tools")
    set_description("Command line tools for use with sokol headers")
    set_license("MIT")

    add_urls("https://github.com/floooh/sokol-tools.git")
    add_versions("2025.02.10", "227e74250e853c0e02e8c77accbe8b31111410be")

    add_deps("cmake", "python 3.x")

    on_install("@macosx", "@linux", "@windows|x64", function (package)
        if os.isdir("fips-build") then
            os.tryrm("./fips-deploy")
            os.tryrm("./fips-build")
            os.tryrm("./fips")
            os.cd("sokol-tools")
            package:set("sourcedir", "sokol-tools")
        end
        if package:is_plat("macosx") then
            os.vrunv("./fips", {"set", "config", "osx-xcode-release"}, {shell = true})
            os.vrunv("./fips", {"build"}, {shell = true})
            os.cp("../fips-deploy/sokol-tools/osx-xcode-release/*", package:installdir("bin"))
        elseif package:is_plat("linux") then
            io.replace("src/shdc/CMakeLists.txt", "-static", "", {plain = true})
            os.vrunv("./fips", {"set", "config", "linux-make-release"}, {shell = true})
            os.vrunv("./fips", {"build"}, {shell = true})
            os.cp("../fips-deploy/sokol-tools/linux-make-release/*", package:installdir("bin"))
        elseif package:is_plat("windows") then
            os.vrunv("fips.cmd", {"set", "config", "win64-vstudio-release"})
            os.vrunv("fips.cmd", {"build"})
            os.cp("../fips-deploy/sokol-tools/win64-vstudio-release/*", package:installdir("bin"))
        end
        os.tryrm("../fips-deploy")
        os.tryrm("../fips-build")
        os.tryrm("../fips")
    end)

    on_test(function (package)
        os.vrun("sokol-shdc -h")
    end)
