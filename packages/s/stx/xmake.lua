package("stx")
    set_homepage("https://lamarrr.github.io/STX")
    set_description("C++17 & C++ 20 error-handling and utility extensions. ")
    set_license("MIT")

    add_urls("https://github.com/lamarrr/STX/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lamarrr/STX.git")

    add_versions("v1.0.5", "d21a1895bc7057c8c6118a042ec39f364b2ad768394d4facb2fd64b73b07d97f")
    add_versions("v1.0.3", "0118b76a5f2a7a60132edecc9b632d9fc82a187bc232ac1a3fd9200fdd92dc7d")

    add_configs("backtrace", {description = "Enable stack backtraces", default = false, type = "boolean"})
    add_configs("custom_handler", {description = "Override the default panic behaviour by implementing a custom panic handler. The default behavior is to print the panic report and abort the program. (You can read the docs for more details)", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared binaries", default = false, type = "boolean", readonly = true})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "iphoneos", "cross", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSTX_ENABLE_BACKTRACE=" .. (package:config("backtrace") and "ON" or "OFF"))
        table.insert(configs, "-DSTX_CUSTOM_PANIC_HANDLER=" .. (package:config("custom_handler") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <stx/option.h>
            using stx::Option, stx::Some, stx::None;
            auto safe_divide(double numerator, double denominator) -> Option<double> {
                if (denominator == 0.0) return None;
                return Some(numerator / denominator);
            }
            void test() {
                safe_divide(5.0, 2.0).match(
                    [](auto value){},
                    [](){});
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
