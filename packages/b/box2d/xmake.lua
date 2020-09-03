package("box2d")

    set_homepage("https://box2d.org")
    set_description("A 2D Physics Engine for Games")

    if is_plat("windows", "linux", "macosx") then
        set_urls("https://github.com/erincatto/box2d/archive/v$(version).zip")
        add_versions("2.4.0", "6aebbc54c93e367c97e382a57ba12546731dcde51526964c2ab97dec2050f8b9")
    end

    add_deps("cmake")

    on_install("windows", "linux", "macosx", function (package)
        local config = {}

        table.insert(config, "-DBOX2D_BUILD_UNIT_TESTS=OFF")
        table.insert(config, "-DBOX2D_BUILD_TESTBED=OFF")
        table.insert(config, "-DBOX2D_BUILD_DOCS=OFF")

        if xmake.version():ge("2.3.7") then
            import("package.tools.cmake").build(package, config, {buildir = "build"})
        else
            local vs_runtime = package:config("vs_runtime")
            if vs_runtime then
                table.insert(config, '-DCMAKE_CXX_FLAGS_DEBUG="/' .. vs_runtime .. 'd"')
                table.insert(config, '-DCMAKE_CXX_FLAGS_RELEASE="/' .. vs_runtime .. '"')
                table.insert(config, '-DCMAKE_C_FLAGS_DEBUG="/' .. vs_runtime .. 'd"')
                table.insert(config, '-DCMAKE_C_FLAGS_RELEASE="/' .. vs_runtime .. '"')
            end
            table.insert(config, "-S")
            table.insert(config, ".")
            table.insert(config, "-B")
            table.insert(config, "build")

            os.mkdir("build")
            os.vrunv("cmake", config)

            if is_plat("windows") then
                local old_dir = os.cd("build")

                local configs = {}
                local arch = package:is_arch("x86") and "Win32" or "x64"
                local mode = package:debug() and "Debug" or "Release"

                table.insert(configs, "/property:Configuration=" .. mode)
                table.insert(configs, "/property:Platform=" .. arch)
                table.insert(configs, "box2d.sln")

                import("package.tools.msbuild").build(package, configs)

                local build_dir = path.join(arch, mode)
                os.cp(path.join(build_dir, "*.lib"), package:installdir("lib"))

                os.cd(old_dir)
            else
                os.vrunv("make", {"-j4"}, {curdir = "build"})
            end

            package:add("linkdirs", "lib")
            package:add("links", "box2d")
        end
        local mode = package:debug() and "Debug" or "Release"

        if is_plat("linux", "macosx") then
            os.trycp("build/src/*.a", package:installdir("lib"))
        else
            os.trycp("build/src/" .. mode .. "/*.lib", package:installdir("lib"))
        end
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
                void test(int argc, char** argv) {
                    b2World world(b2Vec2(0.0f, -10.0f));
                }
            ]]}, {configs = {languages = "c++11"},
                  includes = "box2d/box2d.h"}))
    end)