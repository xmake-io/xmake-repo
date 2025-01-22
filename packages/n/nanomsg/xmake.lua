package("nanomsg")
    set_homepage("https://nanomsg.org")
    set_description([[A simple high-performance implementation of several "scalability protocols".]])

    add_urls("https://github.com/nanomsg/nanomsg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nanomsg/nanomsg.git")

    add_versions("1.2.1", "2e6c20dbfcd4882e133c819ac77501e9b323cb17ae5b3376702c4446261fbc23")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("ws2_32", "mswsock", "advapi32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install(function (package)
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            package:add("defines", "NN_STATIC_LIB")
        end

        if package:has_tool("cc", "gcc") then
            -- TODO: improve this patch
            -- gcc14: https://gcc.gnu.org/pipermail/gcc-cvs/2023-December/394351.html
            -- https://github.com/llvm/llvm-project/issues/74605
            io.replace("src/aio/usock_win.inc", "self->in.start = nn_usock_recv_start_pipe;", "nn_usock_recv_start_pipe(self->in.arg);", {plain = true})
            io.replace("src/aio/usock_win.inc", "self->in.start = nn_usock_recv_start_wsock;", "nn_usock_recv_start_wsock(self->in.arg);", {plain = true})
            io.replace("src/aio/usock_win.inc", "self->in.start (self->in.arg);", "", {plain = true})
        end

        local configs = {"-DNN_ENABLE_DOC=OFF", "-DNN_TESTS=OFF", "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DNN_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DNN_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        if package:config("asan") then
            table.insert(configs, "-DNNG_SANITIZER=address")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nn_allocmsg", {includes = "nanomsg/nn.h"}))
    end)
