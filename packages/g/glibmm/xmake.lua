package("glibmm")
    set_homepage("https://gtkmm.gnome.org")
    set_description("A C++ API for parts of glib that are useful for C++.")
    set_license("LGPL-2.1-or-later")
    -- The giomm library is also built with glibmm. There isn't an option to separate them, under meson build system.

    add_urls("https://gitlab.gnome.org/GNOME/glibmm.git")
    add_urls("https://download.gnome.org/sources/glibmm/$(version).tar.xz", {version = function (version)
        return format("%d.%d/glibmm-%s", version:major(), version:minor(), version)
    end})

    add_versions("2.88.0", "a6549da3a6c43de83b8717dae5413c57a60d92f6ecc624615c612d0bb0ad0fe2")
    add_versions("2.66.8", "64f11d3b95a24e2a8d4166ecff518730f79ecc27222ef41faf7c7e0340fc9329")

    add_configs("deprecated_api", {description = "Build deprecated API and include it in the library", default = true, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean"})

    add_deps("meson", "ninja")

    on_load(function (package)
        -- glibmm doesn't allow static build for MSVC-like compilers.
        if package:toolchain("msvc") then
            package:config_set("shared", true)
        end

        if package:version():lt("2.68") then
            package:add("deps", "libsigcplusplus <3.0.0")
            package:add("deps", "glib >=2.61.2")
            package:add("languages", "c++11")
        else
            package:add("deps", "libsigcplusplus >=3.0.0")
            package:add("deps", "glib >=2.87.3")
            package:add("languages", "c++17")
        end

        local abi = package:version() and package:version():lt("2.68") and "2.4" or "2.68"
        package:add("includedirs",
            "include/glibmm-" .. abi,
            "lib/glibmm-" .. abi .. "/include",
            "include/giomm-" .. abi,
            "lib/giomm-" .. abi .. "/include")
    end)

    on_install("!android and !wasm and !iphoneos", function (package)
        -- Prevent building generate_defs_glib, generate_defs_gio. Otherwise when being built,
        -- errors arise on mingw builds. Doesn't hurt to filter for all platforms.
        io.replace("tools/extra_defs_gen/meson.build", "%s*executable%b()", "", {pattern = true, multiline = true})
        local configs = {"-Dbuild-documentation=false",
                         "-Dbuild-examples=false",
                         "-Dmsvc14x-parallel-installable=false"}
        table.insert(configs, "-Dbuild-deprecated-api=" .. (package:config("deprecated_api") and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int main() {
                Glib::init();
                return 0;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "glibmm.h"}))
    end)
