package("metall")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/LLNL/metall")
    set_description("Persistent memory allocator for data-centric analytics")
    set_license("Apache-2.0")

    add_urls("https://github.com/LLNL/metall/archive/refs/tags/$(version).tar.gz",
             "https://github.com/LLNL/metall.git")

    add_versions("v0.28", "770dedb7f8220c333688b232a22104ca9d8d5823e7a8a21152b58ef970eb85d0")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")
    add_deps("boost")

    on_install(function (package)
        import("package.tools.cmake").install(package, {
            "-DJUST_INSTALL_METALL_HEADER=ON"
        })
    end)

    on_test(function (package)
        assert(package:has_cfuncs("metall_create", {includes = "metall/c_api/metall.h"}))
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
    end)
