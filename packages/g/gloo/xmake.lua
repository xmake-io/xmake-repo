package("gloo")
    set_homepage("https://github.com/pytorch/gloo")
    set_description("Collective communications library with various primitives for multi-machine training.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/pytorch/gloo.git")

    add_versions("2025.07.29", "1dbd7e931568a5e3d6da16c0f2058f0606039640")

    add_configs("mpi",   {description = "Build mpi transport.", default = false, type = "boolean"})
    add_configs("redis", {description = "Support using Redis for rendezvous.", default = false, type = "boolean"})
    add_configs("libuv", {description = "Build libuv transport.", default = false, type = "boolean"})

    if is_plat("linux") then
        add_configs("openssl", {description = "Build TCP-TLS transport with OpenSSL.", default = false, values = {false, "dynlink", "dynload"}})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    on_check(function (package)
        assert(package:is_arch64(), "Gloo can only be built on 64-bit systems.")
    end)

    on_load(function (package)
        if package:config("redis") then
            package:add("deps", "hiredis")
        end
        if package:config("libuv") then
            package:add("deps", "libuv")
        end
        if package:config("openssl") then
            package:add("deps", "openssl")
        end
        if package:config("mpi") then
            package:add("deps", "mpich")
        end
    end)

    on_install("!windows and !mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_REDIS=" .. (package:config("redis") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_LIBUV=" .. (package:config("libuv") and "ON" or "OFF"))
        table.insert(configs, "-DUSE_MPI=" .. (package:config("mpi") and "ON" or "OFF"))
        local openssl = package:config("openssl")
        if openssl == "dynlink" then
            table.insert(configs, "-DUSE_TCP_OPENSSL_LINK=ON")
        elseif openssl == "dynload" then
            table.insert(configs, "-DUSE_TCP_OPENSSL_LOAD=ON")
        end

        io.replace("gloo/types.h", "#include <iostream>", "#include <iostream>\n#include <cstdint>", {plain = true})

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                gloo::rendezvous::Context ctx(1, 2, 3);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "gloo/rendezvous/context.h"}))
    end)
