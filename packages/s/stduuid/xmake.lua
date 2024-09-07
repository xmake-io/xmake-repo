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

    add_deps("cmake")

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
    end)

    on_install(function (package)
        local configs = {"-DUUID_BUILD_TESTS=OFF", "-DUUID_ENABLE_INSTALL=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace uuids;
            void test() {
                uuid empty;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "uuid.h"}))
    end)
