package("visp")
    set_homepage("https://visp.inria.fr")
    set_description("Open Source Visual Servoing Platform.")
    set_license("GPL-2.0")

    add_urls("https://github.com/lagadic/visp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lagadic/visp.git")
    add_versions("v3.7.0", "997f247f3702c83f0a8a6dc2f72ff98cfe3a5dcbd82f7c9f01d37ccd3b8ea97a")

    add_deps("cmake", "eigen", "ffmpeg", "libjpeg", "libpng", "nlohmann_json", "openblas", "openmp", "zlib")

    add_configs("python",    {description = "Build Python bindings", default = false, type = "boolean"})
    add_configs("java",      {description = "Build Java bindings",   default = false, type = "boolean"})
    add_configs("deprecated",{description = "Include deprecated APIs", default = false, type = "boolean"})
    add_configs("sse2",      {description = "Enable SSE2", default = true, type = "boolean"})
    add_configs("sse3",      {description = "Enable SSE3", default = true, type = "boolean"})
    add_configs("ssse3",     {description = "Enable SSSE3", default = true, type = "boolean"})
    add_configs("avx",       {description = "Enable AVX", default = false, type = "boolean"})
    add_configs("namespace", {description = "Use visp namespace", default = true, type = "boolean"})

    local vs_map = {
        ["2015"] = "vc14",
        ["2017"] = "vc15",
        ["2019"] = "vc16",
        ["2022"] = "vc17",
        ["2026"] = "vc18"
    }
    on_load(function (package)
        if package:is_plat("linux", "macosx") and package:config("shared") then
            package:add("deps", "opencv", {configs = {shared = true}})
        else
            package:add("deps", "opencv")
        end
        if package:is_plat("windows") then
            local arch = package:arch()
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            local vs = package:toolchain("msvc"):config("vs")
            local vc_ver = vs_map[vs] or raise("Unknown Visual Studio version: " .. vs)
            package:add("linkdirs", linkdir, path.join(arch, vc_ver, linkdir))
        end
    end)

    on_install("linux", "macosx", "windows|!arm64", function (package)
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DBUILD_APPS=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_TESTS=OFF",
            "-DBUILD_DEMOS=OFF",
            "-DBUILD_TUTORIALS=OFF",
            "-DBUILD_FAT_JAVA_LIB=OFF",
            "-DBUILD_ANDROID_SERVICE=OFF",
            "-DBUILD_ANDROID_PROJECTS=OFF",
            "-DBUILD_ANDROID_EXAMPLES=OFF",
            "-DINSTALL_ANDROID_EXAMPLES=OFF",
            "-DBUILD_PYTHON_BINDINGS_DOC=OFF",
            "-DGENERATE_PYTHON_STUBS=OFF",
            "-DBUILD_PYTHON_BINDINGS=" .. (package:config("python") and "ON" or "OFF"),
            "-DBUILD_JAVA=" .. (package:config("java") and "ON" or "OFF"),
            "-DBUILD_DEPRECATED_FUNCTIONS=" .. (package:config("deprecated") and "ON" or "OFF"),
            "-DENABLE_SSE2=" .. (package:config("sse2") and "ON" or "OFF"),
            "-DENABLE_SSE3=" .. (package:config("sse3") and "ON" or "OFF"),
            "-DENABLE_SSSE3=" .. (package:config("ssse3") and "ON" or "OFF"),
            "-DENABLE_AVX=" .. (package:config("avx") and "ON" or "OFF"),
            "-DENABLE_VISP_NAMESPACE=" .. (package:config("namespace") and "ON" or "OFF"),
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <visp3/core/vpImage.h>
            void test() {
            #ifdef ENABLE_VISP_NAMESPACE
                visp::vpImage<unsigned char> img(640, 480);
            #else
                vpImage<unsigned char> img(640, 480);
            #endif
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
