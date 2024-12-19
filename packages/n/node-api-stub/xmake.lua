package("node-api-stub")

    set_homepage("https://github.com/napi-bindings/node-api-stub")
    set_description("Node-API stub")
    set_license("MIT")

    add_urls("https://github.com/napi-bindings/node-api-stub.git")
    add_urls("https://github.com/napi-bindings/node-api-stub/archive/refs/tags/$(version).tar.gz")

    add_versions("8.0.0", "7fdf725a3122f4d86443e707227a30c663c7163c6d1b9f883cb2305f18e01740")
    add_patches("8.0.0", path.join(os.scriptdir(), "patches", "cmake.patch"), "ed3edac79b7efa682553e6dc85b5479f111445fc4df2e1b9674c5d7583cfb945")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    add_links("node_api")

    on_install("windows", "macosx", "linux", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                void *p, *q;
                napi_get_undefined(p, q);
            }
        ]]}, {configs = {languages = "c99"}}))
    end)
