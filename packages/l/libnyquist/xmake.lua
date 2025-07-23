package("libnyquist")
    set_homepage("https://github.com/ddiakopoulos/libnyquist")
    set_description(":microphone: Cross platform C++11 library for decoding audio (mp3, wav, ogg, opus, flac, etc) ")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/ddiakopoulos/libnyquist.git")
    add_versions("2023.02.12", "767efd97cdd7a281d193296586e708490eb6e54f")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake")
    add_deps("wavpack")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install("windows|!arm64", "linux", "macosx", "bsd", "wasm", function (package)
        local configs = {
            "-DCMAKE_CXX_STANDARD=14",
            "-DLIBNYQUIST_BUILD_EXAMPLE=OFF",
            "-DBUILD_LIBWAVPACK=OFF",
            "-DBUILD_LIBOPUS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        io.replace("include/libnyquist/Common.h", "#if defined(__arm__) || defined(_M_ARM)",
            "#if defined(__arm__) || defined(__arm64) || defined(__arm64__) || (defined(__aarch64__) && __aarch64__) || defined(_M_ARM64) || defined(_M_ARM)", {plain = true})

        io.replace("CMakeLists.txt", "${wavpack_src}", "", {plain = true})
        io.replace("src/WavPackDecoder.cpp", "wavpack.h", "wavpack/wavpack.h", {plain = true})
        os.rm("third_party/wavpack")
        import("package.tools.cmake").install(package, configs, {packagedeps = {"wavpack"}})
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <libnyquist/Decoders.h>
            #include <libnyquist/Encoders.h>
            #include <string>

            using namespace nqr;

            void test() {
                NyquistIO loader;
                std::string arg = "xxx";
                loader.Load(nullptr, arg);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
