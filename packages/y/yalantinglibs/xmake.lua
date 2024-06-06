package("yalantinglibs")
    set_homepage("https://alibaba.github.io/yalantinglibs/")
    set_description("A collection of modern C++ libraries, include coro_rpc, struct_pack, struct_json, struct_xml, struct_pb, easylog, async_simple")
    set_license("Apache-2.0")

    add_urls("https://github.com/alibaba/yalantinglibs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/alibaba/yalantinglibs.git")

    add_versions("0.3.2", "c17107681405977ca80618d0bf93cd3fc19b491937dd296809effdbe87ff02f3")

    add_deps("cmake")

    add_configs("ENABLE_SSL", {description = "Enable optional ssl support for rpc/http",  default = false, type = "boolean"})
    add_configs("ENABLE_PMR", {description = "Enable pmr optimization",  default = false, type = "boolean"})
    add_configs("ENABLE_IO_URING", {description = "Using io_uring as a backend on linux (instead of epoll)",  default = false, type = "boolean"})
    add_configs("ENABLE_FILE_IO_URING	", {description = "Enable io_uring optimizations",  default = false, type = "boolean"})
    add_configs("ENABLE_STRUCT_PACK_UNPORTABLE_TYPE", {description = "struct_pack enables support for special types that are not cross-platform (such as wstring, in128_t)",  default = false, type = "boolean"})
    add_configs("ENABLE_STRUCT_PACK_OPTIMIZE", {description = "struct_pack enables aggressive template expansion optimization (will cost more compilation time)",  default = false, type = "boolean"})

    on_install(function (package)
        import("core.tool.compiler")
        local CPP20_ENABLE = "OFF"
        
        local features = compiler.features("cxx", {configs = {cxxflags = "-std=c++20"}})
        if features then
            CPP20_ENABLE = "ON"
        end

        local configs = {}
        table.insert(configs, "-DENABLE_CPP_20=" .. CPP20_ENABLE)
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DYLT_ENABLE_SSL=" .. (package:config("ENABLE_SSL") and "ON" or "OFF"))
        table.insert(configs, "-DYLT_ENABLE_PMR=" .. (package:config("ENABLE_PMR") and "ON" or "OFF"))
        table.insert(configs, "-DYLT_ENABLE_IO_URING=" .. (package:config("ENABLE_IO_URING") and "ON" or "OFF"))
        table.insert(configs, "-DYLT_ENABLE_FILE_IO_URING=" .. (package:config("ENABLE_FILE_IO_URING") and "ON" or "OFF"))
        table.insert(configs, "-DYLT_ENABLE_STRUCT_PACK_UNPORTABLE_TYPE=" .. (package:config("ENABLE_STRUCT_PACK_UNPORTABLE_TYPE") and "ON" or "OFF"))
        table.insert(configs, "-DYLT_ENABLE_STRUCT_PACK_OPTIMIZE=" .. (package:config("ENABLE_STRUCT_PACK_OPTIMIZE") and "ON" or "OFF"))
        
        table.insert(configs, "-DBUILD_EXAMPLES=OFF")
        table.insert(configs, "-DBUILD_BENCHMARK=OFF")
        table.insert(configs, "-DBUILD_UNIT_TESTS=OFF")
        
        import("package.tools.cmake").install(package, configs)
    end)


    on_test(function (package)
        import("core.tool.compiler")
        local languages = "c++17"
        
        local features = compiler.features("cxx", {configs = {cxxflags = "-std=c++20"}})
        if features then
            languages = "c++20"
        end

        assert(package:check_cxxsnippets({test = [[
            #include "ylt/struct_json/json_reader.h"
            #include "ylt/struct_json/json_writer.h"

            struct person {
            std::string name;
            int age;
            };
            REFLECTION(person, name, age);

            int main() {
            person p{.name = "tom", .age = 20};
            std::string str;
            struct_json::to_json(p, str); // {"name":"tom","age":20}

            person p1;
            struct_json::from_json(p1, str);
            }
        ]]}, {configs = {languages = languages}}))
    end)
