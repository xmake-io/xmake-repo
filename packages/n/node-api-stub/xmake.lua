package("node-api-stub")
    set_homepage("https://github.com/napi-bindings/node-api-stub")
    set_description("Node-API stub")
    set_license("MIT")

    add_urls("https://github.com/napi-bindings/node-api-stub/archive/refs/tags/$(version).tar.gz",
             "https://github.com/napi-bindings/node-api-stub.git")

    add_versions("8.0.0", "7fdf725a3122f4d86443e707227a30c663c7163c6d1b9f883cb2305f18e01740")

    on_install(function (package)
        if package:has_tool("cxx", "cl") then
            io.replace("node_api.c", "void exit()  __attribute__((noreturn));", "NAPI_NO_RETURN void exit();", {plain = true})
        end
        if package:is_plat("windows") then
            if package:config("shared") then
                package:add("defines", "NAPI_EXTERN=__declspec(dllimport)")
            else
                io.replace("js_native_api.h", "__declspec(dllexport)", "", {plain = true})
            end
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("node-api-stub")
                set_kind("$(kind)")
                add_files("node_api.c")
                add_headerfiles("*.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("napi_get_undefined", {includes = "node_api.h"}))
    end)
