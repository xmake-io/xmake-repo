package("field-reflection")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/yosh-matsuda/field-reflection")
    set_description("Compile-time reflection for C++ to get field names and types from a struct/class.")
    set_license("MIT")

    add_urls("https://github.com/yosh-matsuda/field-reflection/archive/refs/tags/$(version).tar.gz",
             "https://github.com/yosh-matsuda/field-reflection.git")

    add_versions("v0.2.1", "42c92b98e441b5d01d02d02b6cdeaca019975f81dfafc2650ea6c207cadac538")
    add_versions("v0.2.0", "4fa3ac60940054954d873d2845619cfec3492b7c1feaad0f95a3b6f52bbb4124")
    add_versions("v0.1.0", "1d8feeacc9aba8271a70ad71a1bac31789b4626056785754f7accab2c2522985")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <array>
            #include <cstdint>
            #include <map>
            #include <string>
            #include <iostream>
            #include <field_reflection.hpp>

            using namespace field_reflection;

            struct my_struct
            {
                int i = 287;
                double d = 3.14;
                std::string hello = "Hello World";
                std::array<std::uint64_t, 3> arr = {1, 2, 3};
                std::map<std::string, int> map{{"one", 1}, {"two", 2}};
            };

            // get field names
            constexpr auto my_struct_n0 = field_name<my_struct, 0>;  // "i"sv
            constexpr auto my_struct_n1 = field_name<my_struct, 1>;  // "d"sv
            constexpr auto my_struct_n2 = field_name<my_struct, 2>;  // "hello"sv
            constexpr auto my_struct_n3 = field_name<my_struct, 3>;  // "arr"sv
            constexpr auto my_struct_n4 = field_name<my_struct, 4>;  // "map"sv

            // get field types
            using my_struct_t0 = field_type<my_struct, 0>;  // int
            using my_struct_t1 = field_type<my_struct, 1>;  // double
            using my_struct_t2 = field_type<my_struct, 2>;  // std::string
            using my_struct_t3 = field_type<my_struct, 3>;  // std::array<uint64_t, 3>
            using my_struct_t4 = field_type<my_struct, 4>;  // std::map<std::string, int>

            // get field values with index
            auto s = my_struct{};
            auto& my_struct_v0 = get_field<0>(s);  // s.i
            auto& my_struct_v1 = get_field<1>(s);  // s.d
            auto& my_struct_v2 = get_field<2>(s);  // s.hello
            auto& my_struct_v3 = get_field<3>(s);  // s.arr
            auto& my_struct_v4 = get_field<4>(s);  // s.map

            int main() {
                // visit each field
                for_each_field(s, [](std::string_view field, auto& value) {
                    // i: 287
                    // d: 3.14
                    // hello: Hello World
                    // arr: [1, 2, 3]
                    // map: {"one": 1, "two": 2}
                    std::cout << "Containing " << field << std::endl;
                });
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
