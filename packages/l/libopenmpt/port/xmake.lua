add_requires("zlib", "mpg123", "libvorbis")

add_rules("mode.release", "mode.debug")

set_languages("c++17")

target("openmpt")
    set_kind("$(kind)")
    add_files(
        "common/*.cpp",
        "soundbase/*.cpp",
        "sounddsp/*.cpp",
        "soundlib/**.cpp",
        "libopenmpt/libopenmpt_c.cpp",
        "libopenmpt/libopenmpt_cxx.cpp",
        "libopenmpt/libopenmpt_ext_impl.cpp",
        "libopenmpt/libopenmpt_impl.cpp"
    )
    add_includedirs(
        ".",
        "src",
        "build/svn_version",
        "libopenmpt",
        "common",
        "soundbase",
        "sounddsp",
        "soundlib",
        "openmpt123"
    )
    add_headerfiles(
        "libopenmpt/*.h|*_impl.h|*_internal.h",
        "libopenmpt/*.hpp|*_impl.hpp|*_internal.hpp",
        "src/openmpt/all/*.hpp",
        {prefixdir = "libopenmpt"}
    )

    add_defines(
        "MPT_WITH_MPG123",
        "MPT_WITH_OGG",
        "MPT_WITH_VORBIS",
        "MPT_WITH_VORBISFILE",
        "MPT_WITH_ZLIB",
        "MPT_BUILD_VCPKG",
        "LIBOPENMPT_BUILD"
    )
    if is_kind("shared") then
        add_defines("LIBOPENMPT_BUILD_DLL")
    end
    add_packages("zlib", "mpg123", "libvorbis")
