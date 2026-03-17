package("simplecpp")
    set_homepage("https://github.com/danmar/simplecpp")
    set_description("C++ preprocessor")
    set_license("OBSD")

    add_urls("https://github.com/danmar/simplecpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/danmar/simplecpp.git")

    add_versions("1.6.4", "678ae74b16ccabbe6c968475d06a2e9a44dbc8aacb563d17aff338b53205e70a")
    add_versions("1.6.3", "5ee3b2b882f062fbd035675834079d5a3f53555e62f4e32b6291fe817ca84de5")
    add_versions("1.6.1", "d095f0e328fcadaee5300bcaee1807153f7fc5d5eabdd7a0e89f91d05f96fa97")
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
