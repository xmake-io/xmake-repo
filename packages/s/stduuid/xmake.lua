package("stduuid")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mariusbancila/stduuid")
    set_description("A C++17 cross-platform implementation for UUIDs")
    set_license("MIT")

    add_urls("https://github.com/mariusbancila/stduuid/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mariusbancila/stduuid.git")

    add_versions("v1.2.3", "b1176597e789531c38481acbbed2a6894ad419aab0979c10410d59eb0ebf40d3")

    add_configs("system", {description = "Enable operating system uuid generator", default = false, type = "boolean"})
    add_configs("time", {description = "Enable experimental time-based uuid generator", default = false, type = "boolean"})
    add_configs("span", {description = "Using span from std instead of gsl", default = false, type = "boolean"})

    add_deps("cmake")

    add_includedirs("include", "include/stduuid")

    on_load(function (package)
        if package:config("system") then
            package:add("defines", "UUID_SYSTEM_GENERATOR")
            if package:is_plat("macosx") then
                package:add("frameworks", "CoreFoundation")
            elseif not package:is_plat("windows") then
                package:add("deps", "libuuid")
            end
        end
        if package:config("time") then
            package:add("defines", "UUID_TIME_GENERATOR")
        end
        if not package:config("span") then
            package:add("deps", "microsoft-gsl")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "install(FILES include/uuid.h DESTINATION include)", "install(FILES include/uuid.h DESTINATION include/stduuid)", {plain = true})

        local configs = {"-DUUID_BUILD_TESTS=OFF", "-DUUID_ENABLE_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DUUID_USING_CXX20_SPAN=" .. (package:config("span") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        -- Remove bundle deps
        os.tryrm(package:installdir("include/gsl"))
    end)

    on_test(function (package)
        local languages
        if package:config("span") then
            languages = "c++20"
        else
            languages = "c++17"
        end
        assert(package:check_cxxsnippets({test = [[
            using namespace uuids;
            void test() {
                uuid empty;
            }
        ]]}, {configs = {languages = languages}, includes = "uuid.h"}))
    end)
