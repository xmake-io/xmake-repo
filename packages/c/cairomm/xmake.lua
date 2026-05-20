package("cairomm")
    set_homepage("https://www.cairographics.org/cairomm/")
    set_description("cairomm is a C++ wrapper for the cairo graphics library")
    set_license("LGPL-2.1-or-later")

    add_urls("https://www.cairographics.org/releases/cairomm-$(version).tar.xz",
             "https://gitlab.freedesktop.org/cairo/cairomm.git")

    add_versions("1.19.0", "8b14f03a0e5178c7ff8f7b288cb342a61711c84c9fbed6e663442cfcc873ce5b")
    add_versions("1.14.5", "70136203540c884e89ce1c9edfb6369b9953937f6cd596d97c78c9758a5d48db")

    add_configs("deprecated_api", {description = "Build deprecated API and include it in the library", default = false, type = "boolean"})
    add_configs("exceptions_api", {description = "Build exceptions API and include it in the library", default = true, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean"})

    add_deps("meson", "ninja")

    on_load(function (package)
	    local version = package:version()
        local abi = version:lt("1.16") and "1.0" or "1.16"

        if abi == "1.0" then
            package:add("deps", "libsigcplusplus <3.0.0")
            package:add("deps", "cairo >=1.12.0", {configs = {shared = package:config("shared")}})
            package:add("languages", "c++11")
        else
            package:add("deps", "libsigcplusplus >=3.0.0")
            package:add("deps", "cairo >=1.14.0", {configs = {shared = package:config("shared")}})
            package:add("languages", "c++17")
        end

        package:add("includedirs",
            "include/cairomm-" .. abi,
            "lib/cairomm-" .. abi .. "/include")

        if not package:config("shared") then
            package:add("defines", "CAIROMM_STATIC_LIB")
        end
    end)

    on_install("!android and !bsd and !wasm", function (package)
        local configs = {"-Dbuild-documentation=false",
                         "-Dbuild-examples=false",
                         "-Dbuild-tests=false"}
        table.insert(configs, "-Dbuild-deprecated-api=" .. (package:config("deprecated_api") and "true" or "false"))
        table.insert(configs, "-Dbuild-exceptions-api=" .. (package:config("exceptions_api") and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))

        local cxxflags = {}
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            table.insert(cxxflags, "-DCAIROMM_STATIC_LIB")
            table.insert(cxxflags, "-DCAIRO_WIN32_STATIC_BUILD")
        end
        import("package.tools.meson").install(package, configs, {cxxflags = cxxflags})
    end)

    on_test(function (package)
        local language = package:version():lt("1.16") and "c++11" or "c++17"
        assert(package:check_cxxsnippets({test = [[
            int main() {
            #if CAIROMM_MAJOR_VERSION > 1 || (CAIROMM_MAJOR_VERSION == 1 && CAIROMM_MINOR_VERSION >= 15)
                auto surface = Cairo::ImageSurface::create(Cairo::Surface::Format::ARGB32, 10, 10);
            #else
                auto surface = Cairo::ImageSurface::create(Cairo::FORMAT_ARGB32, 10, 10);
            #endif
                return 0;
            }
        ]]}, {configs = {languages = language}, includes = "cairomm/cairomm.h"}))
    end)
