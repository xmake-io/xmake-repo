package("libsimdpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/p12tic/libsimdpp")
    set_description("Portable header-only C++ low level SIMD library")

    add_urls("https://github.com/p12tic/libsimdpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/p12tic/libsimdpp.git")
    add_versions("v2.1", "b0e986b20bef77cd17004dd02db0c1ad9fab9c70d4e99594a9db1ee6a345be93")

    add_deps("cmake")

    add_includedirs("include/libsimdpp-2.1")

    on_install("linux", "macosx", "windows", "bsd", "wasm", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "enable_testing()", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(test)", "", {plain = true})
        import("package.tools.cmake").install(package, configs)
        -- fix some missing headers
        os.cp("simdpp/**.h", package:installdir("include", "libsimdpp-2.1"), {rootdir = "."})
        os.cp("simdpp/**.hpp", package:installdir("include", "libsimdpp-2.1"), {rootdir = "."})
        os.cp("simdpp/**.inl", package:installdir("include", "libsimdpp-2.1"), {rootdir = "."})
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("simdpp::this_compile_arch()", {configs = {languages = "c++14"}, includes = "simdpp/simd.h"}))
    end)
