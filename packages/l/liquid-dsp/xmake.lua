package("liquid-dsp")
    set_homepage("http://liquidsdr.org")
    set_description("digital signal processing library for software-defined radios")
    set_license("MIT")

    add_urls("https://github.com/jgaeddert/liquid-dsp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jgaeddert/liquid-dsp.git")

    add_versions("v1.7.0", "33c42ebc2e6088570421e282c6332e899705d42b4f73ebd1212e6a11da714dd4")

    add_configs("simd", {description = "Build SIMD extensions", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    add_deps("cmake", "fftw")

    on_install(function (package)
        io.replace("CMakeLists.txt", [[execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/version.sh]], "", {plain = true})
        io.replace("CMakeLists.txt", [[WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}]], "", {plain = true})
        io.replace("CMakeLists.txt", [[OUTPUT_VARIABLE LIQUID_VERSION)]], "set(LIQUID_VERSION " .. package:version_str():sub(2) .. ")", {plain = true})
        local configs = {"-DBUILD_EXAMPLES=OFF", "-DBUILD_AUTOTESTS=OFF", "-DBUILD_BENCHMARKS=OFF", "-DBUILD_SANDBOX=OFF", "-DBUILD_DOC=OFF", "-DCOVERAGE=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SIMD=" .. (package:config("simd") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                unsigned int M  = 4;
                unsigned int m  = 12;
                float        As = 60.0f;
                firinterp_crcf interp = firinterp_crcf_create_kaiser(M,m,As);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "liquid/liquid.h"}))
    end)
