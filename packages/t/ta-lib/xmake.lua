package("ta-lib")
    set_homepage("https://github.com/p-ranav/tabulate")
    set_description("Technical Analysis Library for financial market trading applications")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/TA-Lib/ta-lib/releases/download/v$(version)/ta-lib-$(version)-src.tar.gz")
    add_versions("0.6.2", "598164dd030546eac7385af9b311a4115bb47901971c74746cbef4d3287c81e0")         

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                TA_Initialize();
                TA_Shutdown();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "ta-lib/ta_libc.h"}))
    end)