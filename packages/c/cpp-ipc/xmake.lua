package("cpp-ipc")

    set_homepage("https://github.com/mutouyun/cpp-ipc")
    set_description("A high-performance inter-process communication using shared memory on Linux/Windows")
    set_license("MIT")

    set_urls("https://github.com/mutouyun/cpp-ipc/archive/refs/tags/v$(version).zip",
             "https://github.com/mutouyun/cpp-ipc.git")

    add_versions("1.2.0", "31739760d8f191c7aaf71d1c453fce1989d1f74fdee9a61f9fdd475b29fe1888")

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    on_install("windows", "linux", "mingw", function (package)
        local configs = {"-DLIBIPC_BUILD_TESTS=OFF", "-DLIBIPC_BUILD_DEMOS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBIPC_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("vs_runtime"):startswith("MD") then
            table.insert(configs, "-DLIBIPC_USE_STATIC_CRT=OFF")
        else
            table.insert(configs, "-DLIBIPC_USE_STATIC_CRT=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "libipc/ipc.h"
            void test() { ipc::route cc { "my-ipc-route" }; }
        ]]}, {configs = {languages = "c++17"}}))
    end)
