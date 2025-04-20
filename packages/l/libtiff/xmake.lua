package("libtiff")

    set_homepage("http://www.simplesystems.org/libtiff/")
    set_description("TIFF Library and Utilities.")

    set_urls("https://gitlab.com/libtiff/libtiff/-/archive/$(version)/libtiff-$(version).tar.gz",
             "https://gitlab.com/libtiff/libtiff.git")
    add_versions("v4.1.0", "fddd8838e7e57ba20a93b17706c3f9fe68c8711a6321f04b9ce9a9c24196ac74")
    add_versions("v4.2.0", "f87463ac8984b43e8dd84a04c14816f5f217796d9f1f459756239c499857e75a")
    add_versions("v4.3.0", "5abe48cb2ea469fefb36d85718ddb1b9f28f95c87063e006696c83f23f5b8e41")
    add_versions("v4.4.0", "d118fc97748333ae6c53302ea06584148b72e128e924253d346b802d2a80a567")
    add_versions("v4.6.0", "fdd1a2a35b20734a5232527a81d7365eb66e54732bfc44474a3124bcb85221c7")
    add_versions("v4.7.0", "e1d49a419f812cb81626a0c4b2bf0f13c10710fc329284dc9b6dad75b75764bc")

    -- https://gitlab.com/libtiff/libtiff/-/issues/625
    add_patches("4.7.0", "patches/4.7.0/cmath.patch", "007685076f0bcee9b6f22f628b9a21c2331726215da4c863f63b24d66d2cae20")

    add_configs("tools",      {description = "build TIFF tools", default = false, type = "boolean"})
    add_configs("zlib",       {description = "use zlib (required for Deflate compression)", default = false, type = "boolean"})
    add_configs("libdeflate", {description = "use libdeflate (optional for faster Deflate support, still requires zlib)", default = false, type = "boolean"})
    add_configs("jpeg",       {description = "use libjpeg (required for JPEG compression)", default = false, type = "boolean"})
    add_configs("zstd",       {description = "use libzstd (required for ZSTD compression)", default = false, type = "boolean"})
    add_configs("webp",       {description = "use libwebp (required for WEBP compression)", default = false, type = "boolean"})

    if is_plat("macosx") then
        add_extsources("brew::libtiff/libtiff-4")
    end

    local configdeps = {zlib       = "zlib",
                        libdeflate = "libdeflate",
                        jpeg       = "libjpeg-turbo",
                        zstd       = "zstd",
                        webp       = "libwebp"}

    add_deps("cmake")
    on_load("windows", "mingw", "macosx", "linux", "bsd", function (package)
        for config, dep in pairs(configdeps) do
            if package:config(config) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("windows", "mingw", "macosx", "linux", "bsd", function (package)
        local configs = {"-Dlzma=OFF", "-Djbig=OFF", "-Dpixarlog=OFF", "-Dlerc=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        for config, dep in pairs(configdeps) do
            table.insert(configs, "-D" .. config .. "=" .. (package:config(config) and "ON" or "OFF"))
        end
        io.replace("CMakeLists.txt", "add_subdirectory(man)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(html)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(test)", "", {plain = true})
        if not package:config("tools") then
            io.replace("CMakeLists.txt", "add_subdirectory(tools)", "", {plain = true})
        else
            package:addenv("PATH", "bin")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("TIFFOpen", {includes = "tiffio.h"}))
    end)
