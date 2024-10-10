package("ittapi")
    set_homepage("https://github.com/intel/ittapi")
    set_description("Intel® Instrumentation and Tracing Technology (ITT) and Just-In-Time (JIT) API")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/intel/ittapi/archive/refs/tags/$(version).tar.gz",
             "https://github.com/intel/ittapi.git")

    add_versions("v3.25.3", "1b46fb4cb264a2acd1a553eeea0e055b3cf1d7962decfa78d2b49febdcb03032")
    add_versions("v3.25.2", "1d76613b29f4b7063dbb2b54e9ef902e36924c5dd016fee1d7b392b3d4ee66c2")
    add_versions("v3.25.1", "866a5a75a287a7440760146f99bd1093750c3fb5bf572c3bff2d4795628ebc7c")
    add_versions("v3.24.8", "4e57ece3286f3b902d17b1247710f0f6f9a370cc07d5e67631d3656ffac28d81")
    add_versions("v3.24.7", "2ff56c5c3f144b92e34af9bee451115f6076c9070ec92d361c3c07de8ff42649")
    add_versions("v3.24.6", "4e6cb42b6bd9e699e3dfbaf678e572f4292127dfee3312744137ac567064a26f")
    add_versions("v3.24.4", "f7341c563f228f4358b645fce526208c742fe13e61fc3ba2c777ba94d36e98f5")

    add_configs("force_32", {description = "Force a 32bit compile on 64bit", default = false, type = "boolean"})
    add_configs("ipt", {description = "ptmarks support", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared binaries.", default = false, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_syslinks("dl")
    end

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DFORCE_32=" .. (package:config("force_32") and "ON" or "OFF"))
        table.insert(configs, "-DITT_API_IPT_SUPPORT=" .. (package:config("ipt") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ittnotify.h>
            void test() {
                __itt_string_handle* nameHandle = __itt_string_handle_create("");
            }
        ]]}))
    end)
