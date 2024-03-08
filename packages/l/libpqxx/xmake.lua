package("libpqxx")
    set_homepage("http://pqxx.org/")
    set_description("The official C++ client API for PostgreSQL.")

    add_urls("https://github.com/jtv/libpqxx/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jtv/libpqxx.git")
    add_versions("7.9.0", "a1fafd5f6455f6c66241fca1f35f5cb603251580b99f9a0cf1b5d0a586006f16")
    add_versions("7.8.1", "0f4c0762de45a415c9fd7357ce508666fa88b9a4a463f5fb76c235bc80dd6a84")
    add_versions("7.7.0", "2d99de960aa3016915bc69326b369fcee04425e57fbe9dad48dd3fa6203879fb")

    add_deps("cmake", "python 3.x")
    add_deps("xmlto", "libpq")

    on_install("linux", "macosx", function (package)
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

