package("cpp-ipc")
    set_homepage("https://github.com/mutouyun/cpp-ipc")
    set_description("A high-performance inter-process communication using shared memory on Linux/Windows")
    set_license("MIT")

    set_urls("https://github.com/mutouyun/cpp-ipc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mutouyun/cpp-ipc.git")

    add_versions("v1.4.1", "055bd95a066936e0d6f30eab9fe3b4414aa3ce97d8ac03fbd5c9009591ad170b")
    add_versions("v1.3.0", "a5ffb67ff451aa28726ab7801509c5c67feb737db49d2be4f7c70a4e9fad2fee")
    add_versions("v1.2.0", "c8df492e08b55e0722eb3e5684163709c1758f3282f05358ff78c694eadb6e60")

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("advapi32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install("windows", "linux", "mingw", "msys", "cross", function (package)
        if package:config("shared") then
            package:add("defines", "LIBIPC_LIBRARY_SHARED_USING__")
        end

        io.replace("src/CMakeLists.txt", "if(NOT MSVC)", "if(NOT WIN32)", {plain = true})

        local configs = {"-DLIBIPC_BUILD_TESTS=OFF", "-DLIBIPC_BUILD_DEMOS=OFF", "-DLIBIPC_USE_STATIC_CRT=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBIPC_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local opt = {}
        if package:has_tool("cxx", "clang_cl") then
            opt.cxflags = "/EHsc"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "libipc/ipc.h"
            void test() { ipc::route cc { "my-ipc-route" }; }
        ]]}, {configs = {languages = "c++17"}}))
    end)
