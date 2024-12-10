package("iguana")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/qicosmos/iguana")
    set_description("universal serialization engine")
    set_license("Apache-2.0")

    add_urls("https://github.com/qicosmos/iguana/archive/refs/tags/$(version).tar.gz",
             "https://github.com/qicosmos/iguana.git")

    add_versions("1.0.6", "cfacf1cce4ebe49b947ec823f93a23c2a7fd220f67f6847e9f449e7c469deb9e")
    add_versions("1.0.5", "b7a7385c49574a60f9f6bf887c1addbc08f557a0117bf18cf7eec532ac2536b1")
    add_versions("1.0.4", "b584cd26e65902a14a3a349ebc480beb7b4502fd5a5ffa3cb7c6102d857958b1")
    add_versions("v1.0.3", "7dcb21a36bd64a63a9ea857f3563ac61e965c49ec60ad7b99a2bfb9192f3e4c3")

    add_deps("frozen")

    on_install(function (package)
        os.vcp("iguana", package:installdir("include"))
    end)

    on_test(function (package)
        local languages = "c++17"
        if package:is_plat("windows") and package:is_arch("arm.*") then
            languages = "c++20"
        end

        local reflection_macro = package:version():ge("1.0.6") and "YLT_REFL" or "REFLECTION"
        local snippets = string.format([[
            #include <iguana/json_reader.hpp>
            struct some_obj {
                std::string_view name;
                iguana::numeric_str age;
            };
            %s(some_obj, name, age);
            void test() {
                some_obj obj;
                std::string_view str = "{\"name\":\"tom\", \"age\":20}";
                iguana::from_json(obj, str);
            }
        ]], reflection_macro)
        assert(package:check_cxxsnippets({test = snippets}, {configs = {languages = languages}}))
    end)
