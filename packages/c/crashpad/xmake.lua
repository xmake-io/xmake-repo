package("crashpad")
    set_homepage("https://chromium.googlesource.com/crashpad/crashpad/+/refs/heads/main/README.md")
    set_description("Crashpad is a crash-reporting system.")
    set_license("Apache-2.0")

    add_urls("https://github.com/getsentry/crashpad.git")
    add_versions("2024.04.15", "96e301b7d6b81990a244d7de41a0d36eeb60899e")

    add_includedirs("include/crashpad", "include/crashpad/mini_chromium")
    add_links("crashpad_client", "crashpad_util", "mini_chromium")

    add_deps("cmake")
    add_deps("libcurl")

    on_install("linux", "windows|x64", "windows|x86", function(package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "libcurl"})
        package:addenv("PATH", "bin")
    end)

    on_test(function(package)
        if not package:is_cross() then
            os.vrun("crashpad_handler --help")
        end

        assert(package:check_cxxsnippets({test = [[
            #include "client/crashpad_client.h"
            using namespace crashpad;
            void test() {
                CrashpadClient *client = new CrashpadClient();
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
