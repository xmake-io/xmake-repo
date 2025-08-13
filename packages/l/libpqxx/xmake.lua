package("libpqxx")
    set_homepage("http://pqxx.org/")
    set_description("The official C++ client API for PostgreSQL.")

    add_urls("https://github.com/jtv/libpqxx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jtv/libpqxx.git")
             
    add_versions("7.10.1", "9bfaf9cb5a73ac23f9b7a9dfd7ef069a6e2124fb")
    add_versions("7.7.0", "2d99de960aa3016915bc69326b369fcee04425e57fbe9dad48dd3fa6203879fb")

    add_deps("cmake", "libpq")

    on_install("windows|!arm64 or macosx|!arm64 or linux|!arm64 or bsd|!arm64", function (package)
        local configs = {"-DSKIP_BUILD_TEST=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
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

