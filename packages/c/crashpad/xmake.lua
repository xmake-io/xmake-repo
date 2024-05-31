package("crashpad")
    set_homepage("https://chromium.googlesource.com/crashpad/crashpad/+/refs/heads/main/README.md")
    set_description("Crashpad is a crash-reporting system.")
    set_license("Apache-2.0")

    add_urls("https://github.com/getsentry/crashpad.git")
    add_versions("2024.04.15", "96e301b7d6b81990a244d7de41a0d36eeb60899e")
    add_deps("libcurl")

    on_install("linux|x64", "windows|x64","linux|x86", "windows|x86", function(package)
        local configs = {}
        import("package.tools.cmake").install(package, configs, {
            packagedeps = {"libcurl"}
        })
        package:addenv("PATH", "bin")
    end)

    add_includedirs("include/crashpad", "include/crashpad/mini_chromium")
    add_links("crashpad_client", "crashpad_util", "mini_chromium")

    on_test(function(package)
        if package:is_plat("linux") then
            os.vrunv("crashpad_handler", {"--help"})
        end

        if package:is_plat("windows") then
            os.vrunv("crashpad_handler.exe", {"--help"})
        end

        assert(package:check_cxxsnippets({
            test = [[
                                    #include "client/crashpad_client.h"
                                    using namespace crashpad;
                                    void test() {
                                        CrashpadClient *client = new CrashpadClient();
                                    }
                                ]]
        }, {
            configs = {
                languages = "cxx17"
            }
        }))

    end)
