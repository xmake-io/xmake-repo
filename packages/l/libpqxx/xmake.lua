package("libpqxx")
    set_homepage("http://pqxx.org/libpqxx/")
    set_description("The official C++ client API for PostgreSQL.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/jtv/libpqxx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jtv/libpqxx.git")

    -- add_versions("7.10.2", "9e109ffe12daa7b689da41dac05509f41b803f8405e38b1687b54e09df19000f")
    add_versions("7.10.1", "9bfaf9cb5a73ac23f9b7a9dfd7ef069a6e2124fb")
    add_versions("7.7.0", "2d99de960aa3016915bc69326b369fcee04425e57fbe9dad48dd3fa6203879fb")

    add_deps("cmake", "libpq")

    on_check(function (package)
        if package:is_plat("windows") and package:is_arch("arm64") then
            raise("package(libpqxx): ARM64 support on Windows is unavailable due to its dependence libpq.")
        end
    end)

    on_install("windows", "macosx", "linux", "bsd", function (package)
        if package:is_plat("windows") and package:version():eq("7.10.2") then
            io.replace("include/pqxx/internal/header-pre.hxx", "#if PQXX_CPLUSPLUS < 201703L && __has_include(<ciso646>)", "#if defined(_MSC_VER) && PQXX_CPLUSPLUS <= 201703L && __has_include(<ciso646>)", {plain=true})
        end
        local configs = {"-DSKIP_BUILD_TEST=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
              pqxx::connection con;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "pqxx/pqxx"}))
    end)
