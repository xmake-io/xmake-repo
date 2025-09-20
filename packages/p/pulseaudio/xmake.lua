package("pulseaudio")
    set_homepage("https://www.freedesktop.org/wiki/Software/PulseAudio/")
    set_description("A featureful, general-purpose sound server")
    set_license("LGPL-2.1-or-later")

    add_urls("https://github.com/pulseaudio/pulseaudio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/pulseaudio/pulseaudio.git")
    add_versions("v17.0", "ed36c8a0cdff7b57382a258d3e1a916f42500fbafd64dd3c2e258ed8f017ee90")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    add_extsources("pkgconfig::libpulse")
    if is_plat("linux") then
        add_extsources("pacman::libpulse", "apt::libpulse-dev")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("meson", "ninja")
    if is_plat("linux") then
        add_deps("alsa-lib")
    end
    add_deps("dbus", "fftw", "glib", "jack2", "libatomic_ops", "libiconv", "libsndfile", "openssl3", "soxr", "speex")

    on_install("linux", function (package)
        -- FFTW dependency has broken CMakeConfig
        io.replace("meson.build",
            "fftw_dep = dependency('fftw3f', required : get_option('fftw'))",
            "fftw_dep = dependency('fftw3', method: 'pkg-config', required : get_option('fftw'))", {plain = true})
        -- SndFile dependency has 4 FindDep.cmake files
        io.replace("meson.build",
            "sndfile_dep = dependency('sndfile', version : '>= 1.0.20')",
            "sndfile_dep = dependency('SndFile', method: 'cmake')", {plain = true})
        if package:version_str() then
            local v = package:version_str():gsub("v", "")
            io.writefile(".tarball-version", v)
            os.rm("git-version-gen")
            io.replace("meson.build",
                "run_command(find_program('git-version-gen'), join_paths(meson.current_source_dir(), '.tarball-version'), check : false).stdout().strip()",
                "'" .. v .. "'", {plain = true})
        end
        local configs = {
            "-Dgstreamer=disabled",
            "-Ddaemon=false",
            "-Dclient=true",
            "-Ddoxygen=false",
            "-Dgcov=false",
            "-Dman=false",
            "-Dtests=false",
            "-Dbashcompletiondir=no",
            "-Dzshcompletiondir=no",
            "-Dasyncns=disabled",
            "-Davahi=disabled",
            "-Dbluez5=disabled",
            "-Dconsolekit=disabled",
            "-Ddbus=enabled",
            "-Delogind=disabled",
            "-Dfftw=enabled",
            "-Dglib=enabled",
            "-Dgsettings=disabled",
            "-Dgtk=disabled",
            "-Dhal-compat=false",
            "-Dipv6=true",
            "-Djack=enabled",
            "-Dlirc=enabled",
            "-Dopenssl=enabled",
            "-Dorc=disabled",
            "-Dsoxr=enabled",
            "-Dspeex=enabled",
            "-Dsystemd=disabled",
            "-Dtcpwrap=disabled",
            "-Dudev=disabled",
            "-Dvalgrind=disabled",
            "-Dx11=disabled",
            "-Dadrian-aec=false",
            "-Dwebrtc-aec=disabled"
        }

        table.insert(configs, "-Dalsa=" .. (package:is_plat("linux") and "enabled" or "disabled"))
        table.insert(configs, "-Doss-output=" .. (package:is_plat("linux") and "enabled" or "disabled"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        
        import("package.tools.meson").install(package, configs, {packagedeps = {"libiconv", "libflac", "libopus", "libvorbis", "libogg"}})
        io.writefile(path.join(package:installdir("lib"), "cmake", "PulseAudio", "PulseAudioConfig.cmake"), [[
set(PULSEAUDIO_FOUND TRUE)
set(PULSEAUDIO_VERSION_MAJOR 17)
set(PULSEAUDIO_VERSION_MINOR 0)
set(PULSEAUDIO_VERSION 17.0)
set(PULSEAUDIO_VERSION_STRING "17.0")

find_path(PULSEAUDIO_INCLUDE_DIR
    NAMES pulse/pulseaudio.h
    HINTS "${CMAKE_CURRENT_LIST_DIR}/../../../include"
)

find_library(PULSEAUDIO_LIBRARY
    NAMES pulse libpulse
    HINTS "${CMAKE_CURRENT_LIST_DIR}/../../../lib"
)

find_library(PULSEAUDIO_MAINLOOP_LIBRARY
    NAMES pulse-mainloop-glib libpulse-mainloop-glib
    HINTS "${CMAKE_CURRENT_LIST_DIR}/../../../lib"
)

find_library(PULSEAUDIO_SIMPLE_LIBRARY
    NAMES pulse-simple libpulse-simple
    HINTS "${CMAKE_CURRENT_LIST_DIR}/../../../lib"
)

if(NOT TARGET PulseAudio::PulseAudio)
    add_library(PulseAudio::PulseAudio UNKNOWN IMPORTED)
    set_target_properties(PulseAudio::PulseAudio PROPERTIES
        IMPORTED_LOCATION "${PULSEAUDIO_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${PULSEAUDIO_INCLUDE_DIR}"
        INTERFACE_COMPILE_DEFINITIONS "_REENTRANT"
    )
endif()

if(PULSEAUDIO_MAINLOOP_LIBRARY AND NOT TARGET PulseAudio::MainloopGLib)
    add_library(PulseAudio::MainloopGLib UNKNOWN IMPORTED)
    set_target_properties(PulseAudio::MainloopGLib PROPERTIES
        IMPORTED_LOCATION "${PULSEAUDIO_MAINLOOP_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${PULSEAUDIO_INCLUDE_DIR}"
        INTERFACE_COMPILE_DEFINITIONS "_REENTRANT"
    )
    target_link_libraries(PulseAudio::MainloopGLib INTERFACE PulseAudio::PulseAudio)
endif()

if(PULSEAUDIO_SIMPLE_LIBRARY AND NOT TARGET PulseAudio::PulseAudioSimple)
    add_library(PulseAudio::PulseAudioSimple UNKNOWN IMPORTED)
    set_target_properties(PulseAudio::PulseAudioSimple PROPERTIES
        IMPORTED_LOCATION "${PULSEAUDIO_SIMPLE_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${PULSEAUDIO_INCLUDE_DIR}"
        INTERFACE_COMPILE_DEFINITIONS "_REENTRANT"
    )
    target_link_libraries(PulseAudio::PulseAudioSimple INTERFACE PulseAudio::PulseAudio)
endif()
        ]])
        os.mv(path.join(package:installdir("lib"), "cmake", "PulseAudio", "PulseAudioConfig.cmake"), path.join(package:installdir("lib"), "cmake", "PulseAudioConfig.cmake"))
        os.mv(path.join(package:installdir("lib"), "cmake", "PulseAudio", "PulseAudioConfigVersion.cmake"), path.join(package:installdir("lib"), "cmake", "PulseAudioConfigVersion.cmake"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pa_simple_new", {includes = "pulse/simple.h"}))
    end)
