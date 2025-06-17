package("qwindowkit")
    set_homepage("https://github.com/stdware/qwindowkit")
    set_description("Cross-platform frameless window framework for Qt. Support Windows, macOS, Linux.")
    set_license("Apache-2.0")

    add_urls("https://github.com/stdware/qwindowkit/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stdware/qwindowkit.git")

    add_versions("1.4.0", "6d518d55a8e80243b625dc872b2dd93d753339829fa13e6e2ae071e6c145ed6c")
    add_versions("1.1", "a0102ee4c4fdd08ce35c29a5b9a27384005028b2ab6094f61e467c35917b8c5e")
    add_versions("1.2", "f06b4befc54c6e2c764dbec8a970ce7ffbe561e76a52ea121dca84598f4035b8")

    add_deps("cmake")
    add_deps("qmsetup")
    add_deps("qt6gui")
    if is_plat("linux") then
        add_deps("fontconfig", "libxkbcommon")
    end

    add_includedirs("include/QWindowKit")

    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", function (package)
        local configs = {}
        table.insert(configs, "-Dqmsetup_DIR=" .. package:dep("qmsetup"):installdir("lib"))
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
