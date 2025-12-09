package("msgpack23")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/rwindegger/msgpack23")
    set_description("A modern, header-only C++ library for MessagePack serialization and deserialization. msgpack.org[c++23]")
    set_license("MIT")

    add_urls("https://github.com/rwindegger/msgpack23/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rwindegger/msgpack23.git")

    add_versions("v3.1", "6f0e09f5acc2d5e1e1455d38936aa2cc44a0402ad1d9d1b6cd9203280ff06036")
    add_versions("v2.1", "9ce1e294518aa76cac50f778a359aed17a0daa0d8dc4c1f94cd4f12438b3606c")

    add_deps("cmake")

    on_check(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <utility>
            enum class Color : char {
                red
            };
            void test() {
                std::to_underlying(Color::red);
            }
        ]]}, {configs = {languages = "c++23"}}), "package(msgpack23) require c++23")
    end)

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)

        io.replace(path.join(package:installdir("include/msgpack23"), "msgpack23.h"),
            "#include <cstring>", "#include <cstring>\n#include <utility>", {plain = true})
    end)

    on_test(function (package)
        local code
        if package:version() and package:version():lt("3.0.0") then
            code = [[
                void test() {
                    msgpack23::Packer packer;
                }
            ]]
        else
            code = [[
                void test() {
                    std::vector<std::byte> packedData{};
                    auto const inserter = std::back_insert_iterator(packedData);
                    msgpack23::Packer packer{inserter};
                }
            ]]
        end
        assert(package:check_cxxsnippets({test = code}, {configs = {languages = "c++23"}, includes = "msgpack23/msgpack23.h"}))
    end)
