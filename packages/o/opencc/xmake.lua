package("opencc")

    set_homepage("https://github.com/BYVoid/OpenCC")
    set_description("Conversion between Traditional and Simplified Chinese.")

    set_urls("https://github.com/BYVoid/OpenCC/archive/ver.$(version).zip")
    add_versions("1.1.2", "b4a53564d0de446bf28c8539a8a17005a3e2b1877647b68003039e77f8f7d9c2")

    add_patches("1.1.2", path.join(os.scriptdir(), "patches", "1.1.2", "fix-static.patch"), "a51b58d5d092a057461bc8c7661546cde5c39af3c1f4438abc1d89e1a1df7122")

    add_deps("cmake", {kind = "binary"})
    if not is_plat("bsd") then
        add_deps("python 3.x", {kind = "binary"})
    end

    on_load(function (package)
        if package:is_plat("linux", "mingw") and not package:config("shared") then
            package:add("links", "opencc", "marisa")
        end
        if not package:config("shared") then
            package:add("defines", "Opencc_BUILT_AS_STATIC")
        end
        package:addenv("PATH", "bin")
    end)

    on_install("windows", "mingw@windows,msys", "linux", "macosx", "bsd", function (package)
        local configs = {"-DBUILD_DOCUMENTATION=OFF", "-DENABLE_GTEST=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test("windows", "mingw@windows,msys", "linux", "macosx", "bsd", function (package)
        assert(package:has_cfuncs("opencc_open", {includes = "opencc/opencc.h"}))
        assert(package:check_cxxsnippets({test = [[
            void test() {
                opencc::Config config;
            }
        ]]}, {includes = {"opencc/Config.hpp"}}))
    end)
