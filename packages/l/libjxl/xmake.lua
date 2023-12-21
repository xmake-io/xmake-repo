package("libjxl")

    set_homepage("https://jpeg.org/jpegxl")
    set_description("JPEG XL image format reference implementation")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/libjxl/libjxl.git",
             "https://gitlab.com/wg1/jpeg-xl.git")

    add_versions("v0.8.2", "954b460768c08a147abf47689ad69b0e7beff65e")

    if is_plat("linux") then
        add_syslinks("pthread")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libjxl")
    elseif is_plat("linux") then
        add_extsources("pacman::libjxl", "apt::libjxl-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::jpeg-xl")
    end

    add_configs("sjpg", {description = "Build JPEGXL with support for encoding with sjpeg.", default = false, type = "boolean"})
    add_configs("openexr", {description = "Build JPEGXL with support for OpenEXR if available.", default = false, type = "boolean"})
    add_configs("skcms", {description = "Build with skcms instead of lcms2.", default = false, type = "boolean"})
    add_configs("tcmalloc", {description = "Build JPEGXL using gperftools (tcmalloc) allocator.", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    add_deps("cmake")

    add_links("jxl", "jxl_threads", "brotlienc", "brotlidec", "brotlicommon")

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "wasm", function (package)
        local configs =
        {
            "-DBUILD_TESTING=OFF",
            "-DJPEGXL_ENABLE_FUZZERS=OFF",
            "-DJPEGXL_ENABLE_TOOLS=OFF",
            "-DJPEGXL_ENABLE_DOXYGEN=OFF",
            "-DJPEGXL_ENABLE_MANPAGES=OFF",
            "-DJPEGXL_ENABLE_BENCHMARK=OFF",
            "-DJPEGXL_ENABLE_EXAMPLES=OFF",
        }
        table.insert(configs, "-DJPEGXL_ENABLE_SJPEG=" .. (package:config("sjpg") and "ON" or "OFF"))
        table.insert(configs, "-DJPEGXL_ENABLE_OPENEXR=" .. (package:config("openexr") and "ON" or "OFF"))
        table.insert(configs, "-DJPEGXL_ENABLE_SKCMS=" .. (package:config("skcms") and "ON" or "OFF"))
        table.insert(configs, "-DJPEGXL_ENABLE_TCMALLOC=" .. (package:config("tcmalloc") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DJPEGXL_STATIC=OFF")
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
        else
            table.insert(configs, "-DJPEGXL_STATIC=ON")
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
        end
        io.replace("CMakeLists.txt", "add_subdirectory(tools)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <jxl/decode_cxx.h>
            void test() {
                auto dec = JxlDecoderMake(nullptr);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
