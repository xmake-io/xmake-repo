package("rcmp")
    set_homepage("https://github.com/Smertig/rcmp")
    set_description("C++17, multi-architecture cross-platform hooking library with clean API.")
    set_license("MIT")

    add_urls("https://github.com/Smertig/rcmp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Smertig/rcmp.git")

    add_versions("v0.2.2", "accbf1d2c72b169857900ce816ca3c1718c63c9f67ded413613c236455a331d5")

    add_deps("cmake")
    add_deps("nmd")

    on_install("linux", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        os.rm("external/nmd")
        import("package.tools.cmake").install(package, configs, {packagedeps = "nmd", buildir = "build"})
        local version = package:version()
        if version then
            package:add("defines", "RCMP_VERSION_MAJOR=" .. version:major())
            package:add("defines", "RCMP_VERSION_MINOR=" .. version:minor())
            package:add("defines", "RCMP_VERSION_PATCH=" .. version:patch())
        end
        os.cp("include", package:installdir())
        os.trycp("build/**.a", package:installdir("lib"))
        os.trycp("build/**.so", package:installdir("lib"))
        os.trycp("build/**.dll", package:installdir("bin"))
        os.trycp("build/**.lib", package:installdir("lib"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int bar(float arg) {
                return static_cast<int>(arg) + 5;
            }
            void test() {
                rcmp::hook_function<&bar>([](auto original_bar, float arg) {
                    return original_bar(2 * arg) + 1;
                });
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"rcmp.hpp"}}))
    end)
