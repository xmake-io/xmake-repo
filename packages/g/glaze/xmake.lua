package("glaze")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/stephenberry/glaze")
    set_description("Extremely fast, in memory, JSON and interface library for modern C++")

    add_urls("https://github.com/stephenberry/glaze/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stephenberry/glaze.git")

    add_versions("v2.7.0", "8e3ee2ba725137cd4f61bc9ceb74e2225dc22b970da1c5a43d2a6833115adbfc")
    add_versions("v2.6.4", "79aff3370c6fe79be8e1774c4fab3e450a10444b91c2aa15aeebf5f54efedc5d")
    add_versions("v2.5.3", "f4c5eb83c80f1caa0feaa831715e9982203908ea140242cb061aead161e2b09b")
    add_versions("v2.4.4", "98ef6af4209e0b98d449d6d414b7e0d69b7a79f78d1c9efeb9dfeca011c0600c")
    add_versions("v2.4.2", "2593617e874d6afc33158a68843c74d875e8e443b430aef826d69662459b280e")
    add_versions("v2.3.1", "941bf3f8cea5b6a024895d37dceaaaa82071a9178af63e9935a1d9fd80caa451")
    add_versions("v2.2.0", "1d6e36029a58bf8c4bdd035819e1ab02b87d8454dd80fa2f5d46c96a1e6d600c")
    add_versions("v1.3.5", "de5d59cb7f31193d45f67f25d8ced1499df50c0d926a1461432b87f2b2368817")

    on_install("linux", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <glaze/glaze.hpp>
            struct obj_t {
                double x{};
                float y{};
            };
            template <>
            struct glz::meta<obj_t> {
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
