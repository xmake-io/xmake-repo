package("aubio")
    set_homepage("https://aubio.org")
    set_description("A library for audio and music analysis")
    set_license("GPL-3.0-or-later")

    set_urls("https://github.com/aubio/aubio.git")

    add_versions("2026.4.10", "ad5cf975aed08cc4562dd008cf9f83b12b82ffb8")

    add_configs("sndfile",    {description = "Use libsndfile",          default = false, type = "boolean"})
    add_configs("samplerate", {description = "Use libsamplerate",       default = false, type = "boolean"})
    add_configs("rubberband", {description = "Use rubberband",          default = false, type = "boolean"})
    add_configs("fftw",       {description = "Use FFTW3",               default = false, type = "boolean"})
    add_configs("vorbis",     {description = "Use Ogg Vorbis encoding", default = false, type = "boolean"})
    add_configs("flac",       {description = "Use FLAC encoding",       default = false, type = "boolean"})
    add_configs("accelerate", {description = "Use Accelerate framework (macOS, iOS)", default = true, type = "boolean"})

    add_deps("cmake")

    if is_subhost("windows") then
        add_deps("pkgconf", {host = true})
    else
        add_deps("pkg-config", {host = true})
    end

    on_load(function (package)
        if package:config("sndfile") then
            package:add("deps", "libsndfile")
            --vorbis and flac are dependencies of sndfile, so set options to true.
            package:config_set("vorbis", true)
            package:config_set("flac", true)
        end
        if package:config("samplerate") then
            package:add("deps", "libsamplerate")
        end
        if package:config("rubberband") then
            package:add("deps", "rubberband")
        end
        if package:config("fftw") then
            package:add("deps", "fftw", {configs = {precisions = {"float"}}})
        end
        if package:config("vorbis") then
            package:add("deps", "libvorbis")
        end
        if package:config("flac") then
            package:add("deps", "libflac")
        end
        if package:config("accelerate") and package:is_plat("macosx", "iphoneos") then
            package:add("frameworks", "Accelerate")
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
            "add_library (aubio)", {plain = true})

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

        -- Guard optional dependencies behind cache variables
        local function guard_dep(dep_name, dep_line)
            io.replace("src/CMakeLists.txt",
                "add_optional_dependency (" .. dep_line .. ")",
                "if(DEFINED HAVE_" .. dep_name .. ")\n"
                .. "    if(HAVE_" .. dep_name .. ")\n"
                .. "        target_compile_definitions (aubio PUBLIC HAVE_" .. dep_name .. ")\n"
                .. "    endif()\n"
                .. "else()\n"
                .. "    add_optional_dependency (" .. dep_line .. ")\n"
                .. "endif()",
                {plain = true})
        end
        guard_dep("SNDFILE",    "SNDFILE sndfile>=1.0.4")
        guard_dep("SAMPLERATE", "SAMPLERATE samplerate>=0.0.15")
        guard_dep("RUBBERBAND", "RUBBERBAND rubberband>=1.3")
        guard_dep("VORBISENC",  "VORBISENC vorbisenc vorbis ogg")
        guard_dep("FLAC",       "FLAC flac")

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DHAVE_SNDFILE=" .. (package:config("sndfile") and "ON" or "OFF"))
        table.insert(configs, "-DHAVE_SAMPLERATE=" .. (package:config("samplerate") and "ON" or "OFF"))
        table.insert(configs, "-DHAVE_RUBBERBAND=" .. (package:config("rubberband") and "ON" or "OFF"))
        table.insert(configs, "-DHAVE_VORBISENC=" .. (package:config("vorbis") and "ON" or "OFF"))
        table.insert(configs, "-DHAVE_FLAC=" .. (package:config("flac") and "ON" or "OFF"))

        local extra_cflags = ""
        local extra_shflags = ""

        if package:config("fftw") then
            extra_cflags = extra_cflags .. " -DHAVE_FFTW3"
            if package:toolchain("msvc") then
                extra_shflags = extra_shflags .. " fftw3f.lib"
            else
                extra_shflags = extra_shflags .. " -lfftw3f"
            end
        end

        if package:config("accelerate") and package:is_plat("macosx", "iphoneos") then
            extra_cflags = extra_cflags .. " -DHAVE_ACCELERATE"
            extra_shflags = extra_shflags .. " -framework Accelerate"
        end

        if extra_cflags ~= "" then
           table.insert(configs, "-DCMAKE_C_FLAGS=" .. extra_cflags)
        end
       if extra_shflags ~= "" then
           table.insert(configs, "-DCMAKE_SHARED_LINKER_FLAGS=" .. extra_shflags)
       end

        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        import("package.tools.cmake").install(package, configs, {cmake_build = true})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("new_aubio_onset", {includes = "aubio/aubio.h"}))
    end)
