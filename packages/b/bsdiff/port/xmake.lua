add_requires("zlib")
add_requires("brotli")
add_requires("bzip2")
add_requires("libdivsufsort")
add_requires("libdivsufsort", {
    configs = {
        use_64 = true
    },
    alias = "libdivsufsort64"
})

target("libbspatch")
    set_kind("$(kind)")
    set_languages("c99", "c++17")
    add_files("brotli_decompressor.cc", "bspatch.cc", "bz2_decompressor.cc", "buffer_file.cc", "decompressor_interface.cc",
        "extents.cc", "extents_file.cc", "file.cc", "logging.cc", "memory_file.cc", "patch_reader.cc", "sink_file.cc",
        "utils.cc")
    add_defines("_FILE_OFFSET_BITS=64")
    add_includedirs("include", {
        public = true
    })
    add_headerfiles("include/(bsdiff/*.h)")
    add_includedirs("..")
    add_packages("libdivsufsort", "libdivsufsort64", "brotli", "zlib", "bzip2")

target("libbsdiff")
    set_kind("$(kind)")
    set_languages("c99", "c++17")
    add_files("brotli_compressor.cc", "bsdiff.cc", "bz2_compressor.cc", "compressor_buffer.cc", "diff_encoder.cc",
        "endsley_patch_writer.cc", "logging.cc", "patch_writer.cc", "patch_writer_factory.cc", "split_patch_writer.cc",
        "suffix_array_index.cc")
    add_defines("_FILE_OFFSET_BITS=64")
    add_includedirs("include", {
        public = true
    })
    add_headerfiles("include/(bsdiff/*.h)")

    add_includedirs("..")
    add_packages("libdivsufsort", "libdivsufsort64", "brotli", "zlib", "bzip2")

target("bsdiff")
    set_kind("binary")
    set_languages("c99", "c++17")
    add_includedirs("..")
    add_files("bsdiff_arguments.cc", "bsdiff_main.cc")
    add_packages("brotli")
    add_deps("libbsdiff")

target("bspatch")
    set_kind("binary")
    set_languages("c99", "c++17")
    add_includedirs("..")
    add_files("bspatch_main.cc")
    add_deps("libbspatch")
