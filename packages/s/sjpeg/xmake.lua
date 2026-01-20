package("sjpeg")
    set_homepage("https://github.com/webmproject/sjpeg")
    set_description("SimpleJPEG: simple jpeg encoder")
    set_license("Apache-2.0")

    add_urls("https://github.com/webmproject/sjpeg.git")

    add_versions("2025.06.05", "46da5aec5fce05faabf1facf0066e36e6b1c4dff")

    add_configs("simd", {description = "Enable any SIMD optimization.", default = true, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        io.replace("CMakeLists.txt", "set_target_properties(sjpeg PROPERTIES POSITION_INDEPENDENT_CODE ON)", "", {plain = true})
        io.replace("CMakeLists.txt", "ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}", "ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}\nRUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}", {plain = true})

        local configs = {"-DSJPEG_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        if package:is_plat("android") then
            local ndk = path.unix(package:toolchain("ndk"):config("ndk"))
            table.insert(configs, "-DSJPEG_ANDROID_NDK_PATH=" .. ndk)
        end

        table.insert(configs, "-DSJPEG_ENABLE_SIMD=" .. (package:config("simd") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("SjpegVersion", {includes = "sjpeg.h"}))
    end)
