package("libjxl")
    set_homepage("https://jpeg.org/jpegxl")
    set_description("JPEG XL image format reference implementation")
    set_license("BSD-3-Clause")

    set_urls("https://github.com/libjxl/libjxl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libjxl/libjxl.git",
             "https://gitlab.com/wg1/jpeg-xl.git", {submodules = false})

    add_versions("v0.11.2", "ab38928f7f6248e2a98cc184956021acb927b16a0dee71b4d260dc040a4320ea")
    add_versions("v0.11.1", "1492dfef8dd6c3036446ac3b340005d92ab92f7d48ee3271b5dac1d36945d3d9")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libjxl")
    elseif is_plat("linux") then
        add_extsources("pacman::libjxl", "apt::libjxl-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::jpeg-xl")
    end

    add_configs("sjpg", {description = "Build JPEGXL with support for encoding with sjpeg.", default = false, type = "boolean", readonly = true})
    add_configs("openexr", {description = "Build JPEGXL with support for OpenEXR if available.", default = false, type = "boolean"})
    add_configs("skcms", {description = "Build with skcms instead of lcms2.", default = false, type = "boolean"})
    add_configs("tcmalloc", {description = "Build JPEGXL using gperftools (tcmalloc) allocator.", default = false, type = "boolean"})
    add_configs("jni", {description = "Build JPEGXL JNI Java wrapper.", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_links("jxl", "jxl_threads", "jxl_cms")
    
    add_deps("cmake")
    add_deps("highway", "brotli", "lcms")

    on_load(function (package)
        if package:config("sjpg") then
            package:add("deps", "sjpeg")
        end
        if package:config("openexr") then
            package:add("deps", "openexr")
        end
        if not package:config("shared") then
            package:add("defines", "JXL_STATIC_DEFINE", "JXL_THREADS_STATIC_DEFINE", "JXL_CMS_STATIC_DEFINE")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)", "", {plain = true})
        if (package:is_plat("macosx") and not package:config("shared")) or package:is_plat("iphoneos") then
            io.replace("CMakeLists.txt", "find_package(Atomics REQUIRED)", "find_package(Atomics)", {plain = true})
            io.replace("CMakeLists.txt", "find_package(Threads REQUIRED)", "find_package(Threads)", {plain = true})
            io.replace("lib/jxl_threads.cmake", "find_package(Threads REQUIRED)", "find_package(Threads)", {plain = true})
            io.replace("lib/jxl_threads.cmake", "Threads::Threads", "", {plain = true})
            io.replace("lib/jxl.cmake", "Threads::Threads", "", {plain = true})
        end

        if not package:config("tools") then
            io.replace("CMakeLists.txt", "add_subdirectory(tools)", "", {plain = true})
        end

        local configs =
        {
            "-DBUILD_TESTING=OFF",
            "-DJPEGXL_ENABLE_FUZZERS=OFF",
            "-DJPEGXL_ENABLE_DOXYGEN=OFF",
            "-DJPEGXL_ENABLE_MANPAGES=OFF",
            "-DJPEGXL_ENABLE_BENCHMARK=OFF",
            "-DJPEGXL_ENABLE_EXAMPLES=OFF",
            "-DPROVISION_DEPENDENCIES=OFF",
            "-DJPEGXL_FORCE_SYSTEM_BROTLI=ON",
            "-DJPEGXL_FORCE_SYSTEM_LCMS2=ON",
            "-DJPEGXL_FORCE_SYSTEM_HWY=ON",
            "-DJPEGXL_BUNDLE_LIBPNG=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DJPEGXL_STATIC=OFF")
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
        else
            table.insert(configs, "-DJPEGXL_STATIC=ON")
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
        end
        table.insert(configs, "-DJPEGXL_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))

        table.insert(configs, "-DJPEGXL_ENABLE_SJPEG=" .. (package:config("sjpg") and "ON" or "OFF"))
        table.insert(configs, "-DJPEGXL_ENABLE_OPENEXR=" .. (package:config("openexr") and "ON" or "OFF"))
        table.insert(configs, "-DJPEGXL_ENABLE_SKCMS=" .. (package:config("skcms") and "ON" or "OFF"))
        table.insert(configs, "-DJPEGXL_ENABLE_TCMALLOC=" .. (package:config("tcmalloc") and "ON" or "OFF"))
        table.insert(configs, "-DJPEGXL_ENABLE_JNI=" .. (package:config("jni") and "ON" or "OFF"))
        table.insert(configs, "-DJPEGXL_ENABLE_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
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
