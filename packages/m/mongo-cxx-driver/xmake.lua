package("mongo-cxx-driver")

    set_homepage("https://github.com/mongodb/mongo-cxx-driver")
    set_description("mongodb c++ driver")
    set_license("Apache-2.0")

    add_urls("https://github.com/mongodb/mongo-cxx-driver/archive/r$(version).zip")
    add_versions("3.6.6", "4413de483c5070b48dc5b5c8ee3e32c8e7a2b74b892fe2a55ef78fb758bc01e0")

    add_deps("cmake")
    add_deps("mongo-c-driver")
    if is_plat("windows") then
        add_deps("boost")
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    add_includedirs("include/bsoncxx/v_noabi")
    add_includedirs("include/mongocxx/v_noabi")

    on_install("windows", "macosx", "linux", function (package)
        local configs = {
            "-DBUILD_SHARED_AND_STATIC_LIBS=OFF",
            "-DBUILD_SHARED_LIBS=ON",
            "-DENABLE_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:version() then
            table.insert(configs, "-DBUILD_VERSION=" .. package:version())
        end
        io.replace("CMakeLists.txt", "add_subdirectory(examples EXCLUDE_FROM_ALL)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(benchmark EXCLUDE_FROM_ALL)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory (docs)", "", {plain = true})
        import("package.tools.cmake").install(package, configs, {cmake_build = true, config = (package:debug() and "Debug" or "Release")})
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("mongocxx::instance{nullptr}",
            {configs = {languages = "c++14"}, includes = "mongocxx/instance.hpp"}))
    end)
