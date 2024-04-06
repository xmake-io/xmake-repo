package("faker-cxx")
    set_homepage("https://cieslarmichal.github.io/faker-cxx/")
    set_description("C++ Faker library for generating fake (but realistic) data.")
    set_license("MIT")

    add_urls("https://github.com/cieslarmichal/faker-cxx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cieslarmichal/faker-cxx.git")

    add_versions("v1.0.0", "ffba405f53822cac80491702a6b7c5490dc109474a0f37556bd00ddb69433309")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("faker-cxx")
                set_kind("$(kind)")
                add_files("src/**.cpp")
                remove_files("src/**Test.cpp")
                add_headerfiles("include/(**.h)")
                add_includedirs("include")

                add_cxxflags("cl::/bigobj")
                set_languages("c++20")
                set_encodings("utf-8")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <faker-cxx/Internet.h>
            void test() {
                const auto email = faker::Internet::email();
                const auto password = faker::Internet::password();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
