package("metall")
    set_homepage("https://github.com/LLNL/metall")
    set_description("Persistent memory allocator for data-centric analytics")
    set_license("Apache-2.0")

    add_urls("https://github.com/LLNL/metall/archive/refs/tags/$(version).tar.gz",
             "https://github.com/LLNL/metall.git")

    add_versions("v0.28", "770dedb7f8220c333688b232a22104ca9d8d5823e7a8a21152b58ef970eb85d0")

    add_configs("c_api", {description = "Build C API", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("boost")

    on_load(function (package)
        if not package:config("c_api") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install("macosx", "linux", "bsd", "mingw", "cross", function (package)
        io.replace("CMakeLists.txt", "find_package(Boost 1.64 QUIET)", "find_package(Boost REQUIRED)", {plain = true})

        local configs = {"-DJUST_INSTALL_METALL_HEADER=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_C=" .. (package:config("c_api") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_UTILITY=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <metall/metall.hpp>
            #include <boost/container/vector.hpp>
            using vector_t = boost::container::vector<int, metall::manager::allocator_type<int>>;
            void test() {
                metall::manager manager(metall::open_only, "/tmp/dir");
                auto pvec = manager.find<vector_t>("vec").first;
                pvec->push_back(10);
            }
        ]]}, {configs = {languages = "c++17"}}))

        if package:config("c_api") then
            assert(package:has_cfuncs("metall_create", {includes = "metall/c_api/metall.h"}))
        end
    end)
