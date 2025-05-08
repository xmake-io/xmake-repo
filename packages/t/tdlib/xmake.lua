package("tdlib")
    set_homepage("https://core.telegram.org/")
    set_description("Cross-platform library for building Telegram clients.")
    set_license("BSL-1.0")

    add_deps("cmake", "openssl", "zlib", "gperf")
    add_urls("https://github.com/tdlib/td.git")
    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                td::ClientManager::execute(td::td_api::make_object<td::td_api::setLogVerbosityLevel>(1));
            }
        ]]}, {configs = {languages = "c++17"}, includes = {
            "td/telegram/Client.h",
            "td/telegram/td_api.h",
            "td/telegram/td_api.hpp"
        }}))
    end)
package_end()
