package("gflags")
    set_homepage("https://github.com/gflags/gflags/")
    set_description("The gflags package contains a C++ library that implements commandline flags processing.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/gflags/gflags/archive/refs/tags/$(version).tar.gz",
             "https://github.com/gflags/gflags.git")
    add_versions("v2.3.0", "f619a51371f41c0ad6837b2a98af9d4643b3371015d873887f7e8d3237320b2f")
    add_versions("v2.2.2", "34af2f15cf7367513b352bdcd2493ab14ce43692d2dcd9dfc499492966c64dcf")
    add_patches("v2.2.2", "patches/v2.2.2/fix-cmake.patch", "03c256993c42bf8d1f8dfd100d552fda9e0cf000e02f4aee2fd6b33a3563be56")

    add_configs("mt", {description = "Build the multi-threaded gflags library.", default = true, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("mt") then
            if package:is_plat("windows", "mingw") then
                package:add("syslinks", "shlwapi")
            elseif package:is_plat("linux") then
                package:add("syslinks", "pthread")
            end
        end

        if package:is_plat("windows", "mingw") then
            package:add("defines", "GFLAGS_IS_A_DLL=" .. (package:config("shared") and "1" or "0"))
        end
    end)

    on_install(function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DGFLAGS_REGISTER_BUILD_DIR=OFF",
            "-DGFLAGS_REGISTER_INSTALL_PREFIX=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        if package:config("mt") then
            table.insert(configs, "-DBUILD_gflags_LIB=ON")
            table.insert(configs, "-DBUILD_gflags_nothreads_LIB=OFF")
        else
            table.insert(configs, "-DBUILD_gflags_LIB=OFF")
            table.insert(configs, "-DBUILD_gflags_nothreads_LIB=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using GFLAGS_NAMESPACE::SetUsageMessage;
                SetUsageMessage("Usage message");
            }
        ]]}, {configs = {languages = "c++14"}, includes = "gflags/gflags.h"}))
    end)
