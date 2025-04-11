package("microsoft-kuku")
    set_homepage("https://github.com/microsoft/Kuku")
    set_description("Kuku is a compact and convenient cuckoo hashing library written in C++.")
    set_license("MIT")

    add_urls("https://github.com/microsoft/Kuku/archive/refs/tags/$(version).tar.gz",
             "https://github.com/microsoft/Kuku.git")

    add_versions("v2.1.0", "96ed5fad82ea8c8a8bb82f6eaf0b5dce744c0c2566b4baa11d8f5443ad1f83b7")

    add_configs("c_api",  {description = "Builds C API", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        local version = package:version()
        if version then
            package:add("includedirs", format("include/Kuku-%s.%s", version:major(), version:minor()))
        else
            package:add("includedirs", "include/Kuku-2.1")
        end

        if package:config("c_api") then
            package:add("links", "kukuc", format("kuku-%s.%s", version:major(), version:minor()))
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "if(WIN32 AND BUILD_SHARED_LIBS)", "if(0)", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DKUKU_BUILD_KUKU_C=" .. (package:config("c_api") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "**.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace kuku;
            void test(int argc, char *argv[]) {
                auto table_size = static_cast<table_size_type>(atoi(argv[1]));
                auto stash_size = static_cast<table_size_type>(atoi(argv[2]));
                uint8_t loc_func_count = static_cast<uint8_t>(atoi(argv[3]));
                item_type loc_func_seed = make_random_item();
                uint64_t max_probe = static_cast<uint64_t>(atoi(argv[4]));
                item_type empty_item = make_item(0, 0);

                KukuTable table(table_size, stash_size, loc_func_count, loc_func_seed, max_probe, empty_item);
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"kuku/kuku.h"}}))

        if package:config("c_api") then
            assert(package:has_cxxfuncs("KukuTable_Insert", {includes = "kuku/c/kuku_ref.h"}))
        end
    end)
