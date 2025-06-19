package("libid3tag")
    set_homepage("https://www.underbit.com/products/mad/")
    set_description("ID3 tag manipulation library")
    set_license("GPL-2.0-or-later")

    add_urls("https://codeberg.org/tenacityteam/libid3tag.git",
             "https://codeberg.org/tenacityteam/libid3tag/archive/$(version).tar.gz")

    add_versions("0.16.3", "0561009778513a95d91dac33cee8418d6622f710450a7cb56a74636d53b588cb")

    add_deps("cmake")
    add_deps("zlib")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE="  .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <id3tag.h>
            void test() {
                struct id3_file *fp_mp3 = id3_file_open("song.mp3", ID3_FILE_MODE_READONLY);
                struct id3_tag *tag_mp3 = id3_file_tag(fp_mp3);
                struct id3_frame *frame = id3_tag_findframe(tag_mp3, ID3_FRAME_TITLE, 0);
                id3_file_close(fp_mp3);
            }
        ]]}, {configs = {languages = "c11"}}))
    end)
