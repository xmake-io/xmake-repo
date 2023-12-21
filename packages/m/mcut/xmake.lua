package("mcut")

    set_homepage("https://cutdigital.github.io/mcut.site/")
    set_description("Fast & robust mesh boolean library in C++")
    set_license("GPL-3.0")

    add_urls("https://github.com/cutdigital/mcut/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/cutdigital/mcut.git")
    add_versions("v1.1.0", "a31efbb4c963a40574ee0bad946d02dc77df873f68d35524363bd71d2ae858bd")

    add_patches("1.1.0", path.join(os.scriptdir(), "patches", "1.1.0", "install.patch"), "438f5b76d8ad58253420844248c5da09404cc7ad4a7a19c174e90aacf714d0f0")

    add_deps("cmake")
    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "MCUT_SHARED_LIB")
        end
    end)

    on_install("windows|x86", "windows|x64", "macosx", "linux", "mingw", function (package)
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
