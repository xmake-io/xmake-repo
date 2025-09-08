package("hyprwayland-scanner")
    set_kind("binary")
    set_homepage("https://github.com/hyprwm/hyprwayland-scanner")
    set_description("A Hyprland implementation of wayland-scanner, in and for C++.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/hyprwm/hyprwayland-scanner/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hyprwm/hyprwayland-scanner.git")

    add_versions("v0.4.5", "2125d279eea106e3e6c8dc9fa15181c75d67467b5352d24e2a07903b10abad62")
    add_versions("v0.4.4", "ac73f626019f8d819ff79a5fca06ce4768ce8a3bded6f48c404445f3afaa25ac")

    if is_plat("linux") then
        add_extsources("pacman::hyprwayland-scanner", "apt::hyprwayland-scanner")
    end

    add_deps("pugixml")

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                        #include <format>
                        void test() {
                            auto f = std::format("Hello, {}!", "world");
                        }
                    ]]}, {configs = {languages = "c++23"}}), "package(hyprwayland-scanner) requires c++23")
        end)
    end

    on_install(function (package)
        local version = try { function() return io.readfile("VERSION"):trim() end }
        version = version or (package:version() and package:version_str():gsub("^v", ""))
        version = version or "0.0.0"
        io.replace("src/main.cpp", "SCANNER_VERSION", '"' .. version .. '"', {plain = true})
        if package:is_debug() then
            io.replace("src/main.cpp", "HYPRLAND_DEBUG", "1", {plain = true})
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("pugixml")
            set_languages("c++23")
            target("hyprwayland-scanner")
                set_kind("binary")
                add_files("src/main.cpp")
                add_packages("pugixml")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrunv("hyprwayland-scanner" .. (package:is_plat("windows") and ".exe" or ""), {"--version"})
    end)
