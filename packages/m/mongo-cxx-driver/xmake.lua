package("mongo-cxx-driver")

    set_homepage("https://github.com/mongodb/mongo-cxx-driver")
    set_description("mongodb c++ driver")

    add_urls("https://github.com/mongodb/mongo-cxx-driver/archive/r$(version).zip",
             "https://github.com/mongodb/mongo-cxx-driver.git")
    add_versions("3.6.6", "4413de483c5070b48dc5b5c8ee3e32c8e7a2b74b892fe2a55ef78fb758bc01e0")

    add_deps("mongo-c-driver")
    if is_plat("windows") then
        add_deps("boost")
    end

    on_load("windows", "macosx", "linux", function (package)
        local install_path = package:installdir()
        package:add("includedirs", "/include/bsoncxx/v_noabi")
        package:add("includedirs", "/include/mongocxx/v_noabi")
    end)

    on_install("windows", "macosx", function (package)
        local configs = {"-DBUILD_SHARED_LIBS=ON", 
                         "-DBUILD_SHARED_AND_STATIC_LIBS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:version() then
            table.insert(configs, "-DBUILD_VERSION=" .. package:version())
        end
        import("package.tools.cmake").install(package, configs, {cmake_build = true, config = (package:debug() and "Debug" or "Release")})
    end)

    on_install("linux", function (package)
        -- unbuntu 18.04 下，使用 gcc 编译失败，指定 clang++ 编译
        local configs = {"-DCMAKE_CXX_COMPILER=clang++",
                         "-DBUILD_SHARED_LIBS=ON", 
                         "-DBUILD_SHARED_AND_STATIC_LIBS=OFF"}
        if package:version() then
            table.insert(configs, "-DBUILD_VERSION=" .. package:version())
        end
        import("package.tools.cmake").install(package, configs)
    end)        