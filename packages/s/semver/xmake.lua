package("semver")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Neargye/semver")
    set_description("Semantic Versioning for modern C++")
    set_license("MIT")

    add_urls("https://github.com/Neargye/semver/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Neargye/semver.git")

    add_versions("v1.0.0-rc", "343a667ecf619ead05ba75ccd6bc500e7a809a450b2a79fe3ee92238f2ecf814")

    add_deps("cmake")

    on_install(function (package)
        local configs = {
            "-DSEMVER_OPT_BUILD_EXAMPLES=OFF",
            "-DSEMVER_OPT_BUILD_TESTS=OFF",
            "-DSEMVER_OPT_INSTALL=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <semver.hpp>
            void test() {
                semver::version v1;
                if (semver::parse("1.4.3", v1)) {
                    const int patch = v1.patch(); // 3
                    // do something...
                }
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
