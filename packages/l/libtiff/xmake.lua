package("libtiff")

    set_homepage("http://www.simplesystems.org/libtiff/")
    set_description("TIFF Library and Utilities.")

    set_urls("https://gitlab.com/libtiff/libtiff/-/archive/$(version)/libtiff-$(version).tar.gz",
             "https://gitlab.com/libtiff/libtiff.git")
    add_versions("v4.1.0", "fddd8838e7e57ba20a93b17706c3f9fe68c8711a6321f04b9ce9a9c24196ac74")
    add_versions("v4.2.0", "f87463ac8984b43e8dd84a04c14816f5f217796d9f1f459756239c499857e75a")
    add_versions("v4.3.0", "5abe48cb2ea469fefb36d85718ddb1b9f28f95c87063e006696c83f23f5b8e41")

    add_deps("zlib")
    add_deps("cmake")
    add_deps("libdeflate")

    on_install("windows", "mingw", "macosx", "linux", "bsd", function (package)
        local configs = {"-Dzstd=OFF", "-Dlzma=OFF", "-Dwebp=OFF", "-Djpeg=OFF", "-Djbig=OFF", "-Dpixarlog=OFF", "-Dlerc=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        io.replace("CMakeLists.txt", "add_subdirectory(contrib)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(man)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(html)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(test)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(tools)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("TIFFOpen", {includes = "tiffio.h"}))
    end)
