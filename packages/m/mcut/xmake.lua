package("mcut")

    set_homepage("https://cutdigital.github.io/mcut.site/")
    set_description("Fast & robust mesh boolean library in C++")
    set_license("GPL-3.0")

    add_urls("https://github.com/cutdigital/mcut/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/cutdigital/mcut.git")
    add_versions("v1.1.0", "a31efbb4c963a40574ee0bad946d02dc77df873f68d35524363bd71d2ae858bd")

    add_deps("cmake")
    if is_plat("linux") then
        add_syslinks("pthread")
    end
    on_install("windows", "macosx", "linux", "mingw", function (package)
        local configs = {"-DMCUT_BUILD_TESTS=OFF", "-DMCUT_BUILD_TUTORIALS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPES=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DMCUT_BUILD_AS_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                McContext context = MC_NULL_HANDLE;
                mcCreateContext(&context, MC_NULL_HANDLE);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "mcut/mcut.h"}))
    end)
