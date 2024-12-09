package("jerryscript")
    set_homepage("https://jerryscript.net")
    set_description("Ultra-lightweight JavaScript engine for the Internet of Things.")
    set_license("Apache-2.0")

    add_urls("https://github.com/jerryscript-project/jerryscript.git")

    add_versions("2024.12.03", "c509a06669bd39301fdf0d36305a69689f51919e")

    add_patches("2024.12.03", "patches/2024.12.03/enum.patch", "d8fe23c305a084e400738e7be830691e0dad62699cfbe747e0366683a7c0fc9b")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_configs("cli", {description = "Build jerry command line tool", default = false, type = "boolean"})

    add_deps("cmake")

    if on_check then
        on_check("linux", function (package)
            assert(not package:has_tool("cxx", "clang", "clangxx"), "package(jerryscript): Linux Clang is not supported.")
        end)
    end

    on_install("!mingw and !macosx", function (package)
        local configs = {
            "-DJERRY_CMDLINE=" .. (package:config("cli") and "ON" or "OFF"),
            "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DENABLE_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            if package:config("shared") then
                table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <jerryscript.h>
            void test() {
                jerry_init(JERRY_INIT_EMPTY);
            }
        ]]}, {configs = {languages = "c99"}}))
    end)
