package("simplecpp")
    set_homepage("https://github.com/danmar/simplecpp")
    set_description("C++ preprocessor")
    set_license("OBSD")

    add_urls("https://github.com/danmar/simplecpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/danmar/simplecpp.git")

    add_versions("1.5.2", "ee2b0547f2a889a509263e4b3f6d5764aea2e9536c2f9db545451cbd7994a66c")
    add_versions("1.5.1", "68c893f6f8005fd47ebe720cc5d1cb1664ae282b7607854211248b413105ee50")

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "SIMPLECPP_IMPORT")
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            target("simplecpp")
                set_kind("$(kind)")
                add_files("simplecpp.cpp")
                add_headerfiles("simplecpp.h")
                if is_plat("windows") and is_kind("shared") then
                    add_defines("SIMPLECPP_EXPORT")
                    add_defines("SIMPLECPP_IMPORT", {interface = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <simplecpp.h>

            void test() {
                auto location = simplecpp::Location({});
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
