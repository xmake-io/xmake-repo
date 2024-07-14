package("xtd")
    set_homepage("https://github.com/gammasoft71/xtd")
    set_description("xtd is a modern C++17/20 framework to create console, GUI (forms like WinForms) and unit test applications on Microsoft Windows, Apple macOS, Linux, iOS and android (*).")
    set_license("MIT")

    add_urls("https://github.com/gammasoft71/xtd/archive/refs/tags/v0.1.2-beta.zip",
             "https://github.com/gammasoft71/xtd.git")

    add_versions("v0.1.2", "648f7e5e2252d0db4e9432d493cec0682c059605ae3dfded793884cbbf3d1bd5")

    if is_plat("linux") then
        add_extsources("apt::libgsound-dev")
    end

    add_deps("cmake", "wxwidgets", "alsa-lib", "xorgproto")

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "-DXTD_BUILD_SHARED_LIBRARIES=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DXTD_INSTALL_EXAMPLES=OFF")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <xtd/xtd>
            using namespace xtd;
            static void test() {
                console::background_color(console_color::blue);
                console::foreground_color(console_color::white);
                console::write_line("Hello, World!");
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)