package("gflags")

    set_homepage("https://github.com/gflags/gflags/")
    set_description("The gflags package contains a C++ library that implements commandline flags processing.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/gflags/gflags/archive/refs/tags/$(version).tar.gz",
             "https://github.com/gflags/gflags.git")
    add_versions("v2.2.2", "34af2f15cf7367513b352bdcd2493ab14ce43692d2dcd9dfc499492966c64dcf")

    add_configs("mt", {description = "Build the multi-threaded gflags library.", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("shlwapi")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end
    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("mt") then
            table.insert(configs, "-DBUILD_gflags_LIB=ON")
            table.insert(configs, "-DBUILD_gflags_nothreads_LIB=OFF")
        else
            table.insert(configs, "-DBUILD_gflags_LIB=OFF")
            table.insert(configs, "-DBUILD_gflags_nothreads_LIB=ON")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using GFLAGS_NAMESPACE::SetUsageMessage;
                SetUsageMessage("Usage message");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "gflags/gflags.h"}))
    end)
