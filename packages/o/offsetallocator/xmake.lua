package("offsetallocator")
    set_homepage("https://github.com/sebbbi/OffsetAllocator")
    set_description("Fast O(1) offset allocator with minimal fragmentation")
    set_license("MIT")

    add_urls("https://github.com/sebbbi/OffsetAllocator.git")
    add_versions("2023.03.27", "3610a7377088b1e8c8f1525f458c96038a4e6fc0")

    on_install(function (package)
        if package:is_plat("windows") and package:config("shared") then
            io.replace("offsetAllocator.hpp", "namespace OffsetAllocator", [[
                #define LIBRARY_API __declspec(dllexport)
                namespace OffsetAllocator
            ]], {plain = true})
            io.replace("offsetAllocator.hpp", "struct Allocation", "struct LIBRARY_API Allocation", {plain = true})
            io.replace("offsetAllocator.hpp", "struct Region", "struct LIBRARY_API Region", {plain = true})
            io.replace("offsetAllocator.hpp", "struct StorageReport", "struct LIBRARY_API StorageReport", {plain = true})
            io.replace("offsetAllocator.hpp", "class Allocator", "class LIBRARY_API Allocator", {plain = true})
            io.replace("offsetAllocator.hpp", "struct Node", "struct LIBRARY_API Node", {plain = true})
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("OffsetAllocator")
                set_kind("$(kind)")
                set_languages("c++20")
                add_files("offsetAllocator.cpp")
                add_headerfiles("offsetAllocator.hpp")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using namespace OffsetAllocator;
                Allocator allocator(12345);
                Allocation a = allocator.allocate(1337);
                uint32 offset_a = a.offset;
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"offsetAllocator.hpp"}}))
    end)
