package("yalantinglibs")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/alibaba/yalantinglibs")
    set_description("A collection of modern C++ libraries")
    set_license("Apache-2.0")

    set_urls("https://github.com/alibaba/yalantinglibs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/alibaba/yalantinglibs.git")

    add_versions("0.5.7", "1c1057289e5488f90dd326fd2bb9d3173bad11eb5b06bc0a8bf0fa80857e1cfa")
    add_versions("0.5.6", "b2656f794af30c5b83952b7c73c2dabf949061ddb6284d18d7f0c0560244b35a")
    add_versions("0.5.5", "7962579c1414d1ade4fd22316476723d54112c919514bf1e6015a1870e5e68f7")
    add_versions("0.5.3", "9d24612975d38fa4b4a05bd9f8f5cb65d447365e5eb3661d0eba9701d383523a")
    add_versions("0.5.2", "e63500b9b84b6efd76bfc375d0972c0376d98067f7a6118bfd9a3048d557f46a")
    add_versions("0.4.0", "35d88b5e329f88edb702c1c40a67dedb4438898774c96bb6f3f1704ab828257f")
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

    add_deps("cmake")
    add_deps("cinatra", "iguana")

    on_check("windows", function (package)
        local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
        if vs_toolset then
            local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
            local minor = vs_toolset_ver:minor()
            assert(minor and minor >= 30, "package(yalantinglibs) dep(cinatra) require vs_toolset >= 14.3")
        end
    end)

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
            #include "ylt/coro_http/coro_http_client.hpp"
            #include "ylt/coro_io/coro_file.hpp"

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

            async_simple::coro::Lazy<std::string> test2(std::string path) {
              coro_io::coro_file file(path, std::ios::in | std::ios::binary);
              if (!file.is_open()) {
                throw std::runtime_error("Error opening file: " + path);
              }
            
              auto size = file.file_size();
            
              if (size == 0) {
                co_return "";
              }
            
              std::string content(size, '\0');
              auto [ec, read_size] = co_await file.async_read(content.data(), size);
              if (ec) {
                throw std::runtime_error("Error reading file: " + path + " - " +
                                         ec.message());
              }
            
              if (read_size != size) {
                throw std::runtime_error("Error reading file: " + path +
                                         " - Expected size: " + std::to_string(size) +
                                         ", Read size: " + std::to_string(read_size));
              }
            
              co_return content;
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
