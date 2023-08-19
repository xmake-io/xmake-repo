package("glaze")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/stephenberry/glaze")
    set_description("Extremely fast, in memory, JSON and interface library for modern C++")

    add_urls("https://github.com/stephenberry/glaze/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stephenberry/glaze.git")

    add_versions("v1.3.5", "de5d59cb7f31193d45f67f25d8ced1499df50c0d926a1461432b87f2b2368817")

    on_install(function (package)
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
