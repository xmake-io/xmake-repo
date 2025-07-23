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
    elseif is_plat("android") then
        add_syslinks("m", "c")
    end

    add_deps("cmake", "fftw")

    on_check("android", function (package)
        local ndk = package:toolchain("ndk")
        local ndk_sdkver = ndk:config("ndk_sdkver")
        assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(liquid-dsp): need ndk api level > 21")
    end)

    on_install("!windows", function (package)
        -- if crosscompile do not include FindSIMD.cmake
        io.replace("CMakeLists.txt", [[# check for hardware acceleration]], [[if(NOT CMAKE_CROSSCOMPILING)]], {plain = true})
        io.replace("CMakeLists.txt", [[# TODO: check for FFTW]], [[endif()]], {plain = true})

        -- fix install path and lib kind
        io.replace("CMakeLists.txt", [[lib/static]], [[lib]], {plain = true})
        io.replace("CMakeLists.txt", [[add_library(${LIBNAME} SHARED]], [[add_library(${LIBNAME}]], {plain = true})

        -- gather version from package not from .sh script
        io.replace("CMakeLists.txt", [[execute_process(COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/scripts/version.sh]], "", {plain = true})
        io.replace("CMakeLists.txt", [[WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}]], "", {plain = true})
        io.replace("CMakeLists.txt", [[OUTPUT_VARIABLE LIQUID_VERSION)]], "set(LIQUID_VERSION " .. package:version_str():sub(2) .. ")", {plain = true})

        local configs = {"-DBUILD_EXAMPLES=OFF", "-DBUILD_AUTOTESTS=OFF", "-DBUILD_BENCHMARKS=OFF", "-DBUILD_SANDBOX=OFF", "-DBUILD_DOC=OFF", "-DCOVERAGE=OFF"}
        if is_plat("mingw") then
            io.replace("CMakeLists.txt", [[target_link_libraries(${LIBNAME} c m)]], "target_link_libraries(${LIBNAME} m)", {plain = true})
        end
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
