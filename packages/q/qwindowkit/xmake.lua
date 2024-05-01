package("qwindowkit")
    set_homepage("https://github.com/stdware/qwindowkit")
    set_description("Cross-platform frameless window framework for Qt. Support Windows, macOS, Linux.")
    set_license("Apache-2.0")

    add_urls("https://github.com/stdware/qwindowkit.git")

    add_versions("1.1", "87b7caada401149efda7bfee5289babdbcd5165f")

    add_deps("cmake")
    add_deps("qt6gui")
    if is_plat("linux") then
        add_deps("fontconfig", "libxkbcommon")
    end

    add_includedirs("include/QWindowKit")

    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local cxflags
        if package:is_plat("windows") then
            cxflags = {"/Zc:__cplusplus", "/permissive-"}
        else
            cxflags = "-fPIC"
        end
        assert(package:check_cxxsnippets({test = [[
            #include <QWKWidgets/widgetwindowagent.h>
            void test() {
                QWK::WidgetWindowAgent(nullptr);
            }
        ]]}, {configs = {languages = "c++17", cxflags = cxflags}}))
    end)
