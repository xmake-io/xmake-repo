package("aubio")
    set_homepage("https://aubio.org")
    set_description("A library for audio and music analysis")
    set_license("GPL-3.0-or-later")

    set_urls("https://github.com/aubio/aubio.git")

    add_versions("2026.4.10", "ad5cf975aed08cc4562dd008cf9f83b12b82ffb8")

    add_configs("sndfile",    {description = "Enable libsndfile",    default = false, type = "boolean"})
    add_configs("samplerate", {description = "Enable libsamplerate", default = false, type = "boolean"})
    add_configs("rubberband", {description = "Enable rubberband",    default = false, type = "boolean"})

    add_deps("cmake")

    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end

    on_load(function (package)
        if package:config("sndfile") then
            package:add("deps", "libsndfile")
        end
        if package:config("samplerate") then
            package:add("deps", "libsamplerate")
        end
        if package:config("rubberband") then
            package:add("deps", "rubberband")
        end
    end)

    on_install(function (package)

        -- Enable built-in WAV I/O and C99 variadic macros
        io.replace("src/CMakeLists.txt",
            "target_compile_definitions (aubio PRIVATE HAVE_CONFIG_H)",
            "target_compile_definitions (aubio PRIVATE HAVE_CONFIG_H)\n"
            .. "target_compile_definitions (aubio PRIVATE HAVE_WAVREAD HAVE_WAVWRITE HAVE_C99_VARARGS_MACROS)", {plain = true})

        io.replace("src/CMakeLists.txt",
            "add_library (aubio SHARED)",
            "add_library (aubio " .. (package:config("shared") and "SHARED" or "STATIC") .. ")", {plain = true})

        -- Skip examples and tests
        io.replace("CMakeLists.txt",
            "add_subdirectory (src)\nadd_subdirectory (examples)\nadd_subdirectory (tests)",
            "add_subdirectory (src)", {plain = true})

        -- Install library and headers
        io.replace("src/CMakeLists.txt",
            "set_target_properties (aubio PROPERTIES SOVERSION 5.4.8)",
            'set_target_properties (aubio PROPERTIES SOVERSION 5.4.8)\n'
                .. 'install(TARGETS aubio\n'
                .. '    LIBRARY DESTINATION lib\n'
                .. '    ARCHIVE DESTINATION lib\n'
                .. '    RUNTIME DESTINATION bin)\n'
                .. 'install(DIRECTORY ${CMAKE_SOURCE_DIR}/src/\n'
                .. '    DESTINATION include/aubio\n'
                .. '    FILES_MATCHING PATTERN "*.h"\n'
                .. '    PATTERN "*_priv.h" EXCLUDE\n'
                .. '    PATTERN "config.h" EXCLUDE)', {plain = true})

        -- Guard Windows compat hacks behind if(WIN32)
        io.replace("src/CMakeLists.txt",
            "configure_file (config.h.cmake.in config.h)",
            "configure_file (config.h.cmake.in config.h)\n"
            .. "if(WIN32)\n"
            .. "  target_compile_definitions (aubio PRIVATE HAVE_WIN_HACKS)\n"
            .. "endif()",
            {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        import("package.tools.cmake").install(package, configs, {cmake_build = true})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("new_aubio_onset", {includes = "aubio/aubio.h"}))
    end)