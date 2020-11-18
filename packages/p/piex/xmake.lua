package("piex")

    set_homepage("https://github.com/google/piex")
    set_description("Preview Image Extractor (PIEX)")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/piex.git")
    -- version 20201107 is buggy
    -- add_versions("20201107", "a1b85d566521a4a03c7c715d2851c4272da4e301")
    add_versions("20190530", "84e9cdf11cd8dac8a4977dd1a6a874ddf884d322")

    add_links("piex", "image_type_recognition", "tiff_directory", "binary_parse")
    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        for _, folder in ipairs({"binary_parse", "image_type_recognition", "tiff_directory"}) do
            for _, file in ipairs(os.files(path.join("src", folder, "*.*"))) do
                io.gsub(file, "#include \"src/", "#include \"../")
            end
        end
        for _, file in ipairs(os.files(path.join("src", "*.*"))) do
            io.gsub(file, "#include \"src/", "#include \"")
        end
        io.gsub("src/image_type_recognition/image_type_recognition_lite.cc", "#include <string>", "#include <string>\n#include <cstring>")
        io.gsub("src/image_type_recognition/image_type_recognition_lite.cc", "kSignatureOffset %+ strlen", "kSignatureOffset + std::strlen")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("binary_parse")
                set_kind("static")
                set_languages("c++11")
                add_files("src/binary_parse/cached_paged_byte_array.cc", "src/binary_parse/range_checked_byte_ptr.cc")
                add_headerfiles("src/(binary_parse/cached_paged_byte_array.h)", "src/(binary_parse/range_checked_byte_ptr.h)")
            target("image_type_recognition")
                set_kind("static")
                set_languages("c++11")
                add_deps("binary_parse")
                add_files("src/image_type_recognition/image_type_recognition_lite.cc")
                add_headerfiles("src/(image_type_recognition/image_type_recognition_lite.h)")
            target("tiff_directory")
                set_kind("static")
                set_languages("c++11")
                add_deps("binary_parse")
                add_files("src/tiff_directory/tiff_directory.cc")
                add_headerfiles("src/(tiff_directory/tiff_directory.h)")
            target("piex")
                set_kind("static")
                set_languages("c++11")
                add_deps("binary_parse", "image_type_recognition", "tiff_directory")
                add_files("src/piex.cc", "src/tiff_parser.cc")
                add_headerfiles("src/(piex.h)", "src/(piex_types.h)", "src/(tiff_parser.h)")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("piex::BytesRequiredForIsRaw()", {configs = {languages = "c++11"}, includes = "piex.h"}))
    end)
