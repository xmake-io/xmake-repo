package("ocilib")
    set_homepage("http://www.ocilib.net")
    set_description("OCILIB (C and C++ Drivers for Oracle) - Open source C and C++ library for accessing Oracle databases")
    set_license("Apache-2.0")

    add_urls("https://github.com/vrogier/ocilib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vrogier/ocilib.git")

    add_versions("v4.7.6", "43f5093cac645518ad5bc8d6f48f5b77e12372ef84dc87ddb3a54c40e425bd26")

    add_configs("unicode", {description = "Enable Unicode", default = true, type = "boolean"})

    on_install(function (package)
        local configs = {
            unicode = package:config("unicode")
        }
        if not package:config("shared") then
            package:add("defines", "OCI_LIB_LOCAL_COMPILE")
        end
        io.replace("include/ocilibcpp/detail/core/SmartHandle.hpp",
            ".Set<SmartHandle*>",
            ".template Set<SmartHandle*>", {plain = true})
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("OCI_Initialize", {includes = "ocilib.h"}))
        assert(package:check_cxxsnippets({test = [[
            #include <ocilib.hpp>
            void test() {
                ocilib::Environment::Initialize();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
