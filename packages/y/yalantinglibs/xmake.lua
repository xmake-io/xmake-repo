package("yalantinglibs")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/alibaba/yalantinglibs")
    set_description("A collection of modern C++ libraries")
    set_license("Apache-2.0")

    set_urls("https://github.com/alibaba/yalantinglibs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/alibaba/yalantinglibs.git")

    add_versions("0.3.11", "1766ca1ec977e2dd56dabdcad3172dc1b79c3bd1acd26ea2de019299fa7e888a")
    add_versions("0.3.9", "aea6c5c99297f9b875eac8cabdf846b8f8e792bf7ccb3da8e0afda90ea62f00b")
    add_versions("0.3.8", "a9966687a2ac1ed0b1a001a69e144db4cff4cdf77a5a80c00364e6ea687d3c52")
    add_versions("0.3.7", "b4258806173f63034aa529913601bc3d90da8a598725c0edf0be1a8c5c6f32b8")
    add_versions("0.3.6", "92f694ad42537f95535efc648fc5e73e82f840dae4f54524a096050db398214b")
    add_versions("0.3.4", "dd5edd3f43f23cd4b0614896e6587b61bb38c981dc21c85a54bcc54800d0dfe8")
    add_versions("0.3.5", "8d382573da01449c4f83fccbbc3bdc08d221651f3fc8b9137eb4fbdb703677c2")

    add_configs("ssl", {description = "Enable ssl support", default = false, type = "boolean"})
    add_configs("pmr", {description = "Enable pmr support",  default = false, type = "boolean"})
    add_configs("io_uring", {description = "Enable io_uring",  default = false, type = "boolean"})
    add_configs("file_io_uring", {description = "Enable file io_uring",  default = false, type = "boolean"})
    add_configs("struct_pack_unportable_type", {description = "enable struct_pack unportable type(like wchar_t)",  default = false, type = "boolean"})
    add_configs("struct_pack_unportable_optimize", {description = "enable struct_pack optimize(but cost more compile time)",  default = false, type = "boolean"})

    add_deps("cinatra", "iguana")

    on_load(function (package)
        if package:config("ssl") then
            package:add("deps", "openssl")
            package:add("defines", "YLT_ENABLE_SSL")
        end
        if package:config("pmr") then
            package:add("defines", "YLT_ENABLE_PMR")
        end
        if package:config("io_uring") then
            package:add("deps", "liburing")
            package:add("defines", "ASIO_HAS_IO_URING", "ASIO_DISABLE_EPOLL", "ASIO_HAS_FILE", "YLT_ENABLE_FILE_IO_URING")
        end
        if package:config("file_io_uring") then
            package:add("deps", "liburing")
            package:add("defines", "ASIO_HAS_IO_URING", "ASIO_HAS_FILE", "YLT_ENABLE_FILE_IO_URING")
        end
        if package:config("struct_pack_unportable_type") then
            package:add("defines", "STRUCT_PACK_ENABLE_UNPORTABLE_TYPE")
        end
        if package:config("struct_pack_unportable_optimize") then
            package:add("defines", "YLT_ENABLE_STRUCT_PACK_OPTIMIZE")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {
            "-DINSTALL_THIRDPARTY=OFF",
            "-DINSTALL_STANDALONE=OFF",
            "-DINSTALL_INDEPENDENT_THIRDPARTY=OFF",
            "-DINSTALL_INDEPENDENT_STANDALONE=OFF",
            "-DCMAKE_PROJECT_NAME=xmake",
        }
        for name, enabled in table.orderpairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DYLT_ENABLE_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "ylt/struct_pack.hpp"
            struct person {
                int64_t id;
                std::string name;
                int age;
                double salary;
            };
            void test() {
                person person1{.id = 1, .name = "hello struct pack", .age = 20, .salary = 1024.42};
                std::vector<char> buffer = struct_pack::serialize(person1);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
