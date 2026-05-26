package("pangomm")
    set_homepage("https://gtkmm.gnome.org/")
    set_description("The official C++ interface for the Pango font layout library.")
    set_license("LGPL-2.1")

    add_urls("https://gitlab.gnome.org/GNOME/pangomm.git")
    add_urls("https://download.gnome.org/sources/pangomm/$(version).tar.xz", {version = function (version)
        return format("%d.%d/pangomm-%s", version:major(), version:minor(), version)
    end})

    add_versions("2.56.1", "539f5aa60e9bdc6b955bb448e2a62cc14562744df690258040fbb74bf885755d")
    add_versions("2.46.4", "b92016661526424de4b9377f1512f59781f41fb16c9c0267d6133ba1cd68db22")

    add_configs("deprecated_api", {description = "Build deprecated API and include it in the library", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean"})

    add_deps("meson", "ninja", "pango")

    on_load(function (package)
	    local version = package:version()
        local abi = version:lt("2.48") and "1.4" or "2.48"

        if abi == "1.4" then
            package:add("deps", "glibmm <2.68.0")
            package:add("deps", "cairomm <1.16.0")
            package:add("languages", "c++11")
        else
            package:add("deps", "glibmm >=2.68.0")
            package:add("deps", "cairomm >=1.16.0")
            package:add("languages", "c++17")
        end

        package:add("includedirs",
            "include/pangomm-" .. abi,
            "lib/pangomm-" .. abi .. "/include")

        if not package:config("shared") then
            package:add("defines", "PANGOMM_STATIC_LIB")
        end
    end)

    on_install(function (package)
        local configs = {"-Dbuild-documentation=false",
                         "-Dmaintainer-mode=false",
						 "-Dmsvc14x-parallel-installable=false"}
        table.insert(configs, "-Dbuild-deprecated-api=" .. (package:config("deprecated_api") and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))

        local cxxflags = {}
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            table.insert(cxxflags, "-DPANGOMM_STATIC_LIB")
        end
        import("package.tools.meson").install(package, configs, {cxxflags = cxxflags, packagedeps = "glibmm"})
    end)

    on_test(function (package)
        local language = package:version():lt("2.48") and "c++11" or "c++17"
        assert(package:check_cxxsnippets({test = [[
            int main() {
            #if PANGOMM_MAJOR_VERSION > 2 || (PANGOMM_MAJOR_VERSION == 2 && PANGOMM_MINOR_VERSION >= 48)
                auto alignment = Pango::Alignment::LEFT;
            #else
                auto alignment = Pango::ALIGN_LEFT;
            #endif
                return 0;
            }
        ]]}, {configs = {languages = language}, includes = "pangomm.h"}))
    end)
