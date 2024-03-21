package("glaze")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/stephenberry/glaze")
    set_description("Extremely fast, in memory, JSON and interface library for modern C++")

    add_urls("https://github.com/stephenberry/glaze/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stephenberry/glaze.git")

    add_versions("v1.3.5", "de5d59cb7f31193d45f67f25d8ced1499df50c0d926a1461432b87f2b2368817")
    add_versions("v2.2.0", "1d6e36029a58bf8c4bdd035819e1ab02b87d8454dd80fa2f5d46c96a1e6d600c")
    add_versions("v2.3.1", "941bf3f8cea5b6a024895d37dceaaaa82071a9178af63e9935a1d9fd80caa451")

    on_install("linux", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <glaze/glaze.hpp>
            struct obj_t
            {
                double x{};
                float y{};
            };
            template <>
            struct glz::meta<obj_t>
            {
                using T = obj_t;
                static constexpr auto value = object("x", &T::x);
            };
            void test() {
                std::string buffer{};
                obj_t obj{};
                glz::write_json(obj, buffer);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
