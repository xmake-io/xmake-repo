package("fann")
    set_homepage("https://github.com/libfann/fann")
    set_description("Official github repository for Fast Artificial Neural Network Library (FANN)")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libfann/fann.git")
    add_versions("2021.03.14", "a3cd24e528d6a865915a4fed6e8fac164ff8bfdc")

    add_deps("cmake")

    on_install("linux", "macosx", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "ADD_SUBDIRECTORY( tests )", "", {plain = true})
        io.replace("CMakeLists.txt", "ADD_SUBDIRECTORY( lib/googletest )", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fann_run", {includes = "floatfann.h"}))
    end)
