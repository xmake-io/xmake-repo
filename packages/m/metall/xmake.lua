package("metall")
    set_homepage("https://github.com/LLNL/metall")
    set_description("Persistent memory allocator for data-centric analytics")
    set_license("Apache-2.0")

    add_urls("https://github.com/LLNL/metall/archive/refs/tags/$(version).tar.gz",
             "https://github.com/LLNL/metall.git")

    add_versions("v0.32", "2d373689c56fb41c5e995d786a76845f396099cc5f8bcba0c45a0179a621e235")
    add_versions("v0.31", "d7e1c3d953a31e2fe3adddd7553264e0dc61020d300fa0f0ba409859a68420f3")
    add_versions("v0.30", "d241f45978fceeb83a4b2eda7513466341c45452fa26ec224c5235d00d279d37")

    add_configs("c_api", {description = "Build C API", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("boost", {configs = {cmake = false}})

    on_load(function (package)
        if not package:config("c_api") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install("macosx", "linux", function (package)
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
