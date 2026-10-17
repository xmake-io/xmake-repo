package("saucer")

    set_homepage("https://github.com/saucer/saucer")
    set_description("Build cross-platform desktop apps with C++ & Web Technologies.")
    set_license("MIT")

    add_urls("https://github.com/saucer/saucer/archive/refs/tags/$(version).tar.gz",
             "https://github.com/saucer/saucer.git")

    add_versions("v4.0.0", "2bd9de26c7afba1c8f963f9ae8bd29ea2ab6e18a21f6a757bbd2c9f64918787a")

    local linux_backend = { ["qt5"] = "Qt5", ["qt6"] = "Qt6", ["webkitgtk"] = "WebKitGtk", ["default"] = "WebKitGtk" }

    add_configs("saucer_backend", { description = "linux rendering backend (qt5|qt6|webkitgtk[default])",
            type = "string", default = "default" })
    add_configs("saucer_modules", { description = "enable smartview modules",
            type = "boolean", default = true })
    add_configs("saucer_package_all", { description = "add all required dependencies to install target",
            type = "boolean", default = false })
    add_configs("saucer_prefer_remote", { description = "prefer remote packages over local",
            type = "boolean", default = true })
    add_configs("saucer_msvc_hack", { description = "fix constexpr mutex crashes on msvc",
            type = "boolean", default = false })

    add_deps("cmake", "tl_expected")
    on_load(function(package)
        if is_plat("linux") then
            local sbe = package:config("saucer_backend") and package:config("saucer_backend"):lower() or nil
            assert(linux_backend[sbe], "saucer pkg: unknown Linux backend, '" .. tostring(sbe) .. "'.")
            if sbe[1] == "q" then
                package:add("deps", sbe[1])
            else
                package:add("deps", { "pacman::webkitgtk-6.0", "gtk4" })
            end
            package:add("deps", "pacman::libadwaita")
        end
    end)


    on_install("linux", "windows", "macosx", "mingw", "msys", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-Dsaucer_modules=" .. (package:config("saucer_modules") and "ON" or "OFF"))
        table.insert(configs, "-Dsaucer_package_all=" .. (package:config("saucer_package_all") and "ON" or "OFF"))
        table.insert(configs, "-Dsaucer_prefer_remote=" .. (package:config("saucer_prefer_remote") and "ON" or "OFF"))

        if is_plat("windows") then
            table.insert(configs, "-Dsaucer_msvc_hack=" .. (package:config("saucer_msvc_hack") and "ON" or "OFF"))
        elseif is_plat("linux") then
            local sbe = package:config("saucer_backend"):lower()
            table.insert(configs, "-Dsaucer_backend=" .. linux_backend[sbe])
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <saucer/smartview.hpp>

            void test()
            {
                auto app = saucer::application::acquire({
                    .id = "package",
                });
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)

