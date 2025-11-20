package("highs")
    set_homepage("https://github.com/ERGO-Code/HiGHS")
    set_description("Linear optimization software")
    set_license("MIT")

    add_urls("https://github.com/ERGO-Code/HiGHS/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ERGO-Code/HiGHS.git")

    add_versions("v1.12.0", "cd0daddaca57e66b55524588d715dc62dcee06b5ab9ad186412dc23bc71ae342")
    add_versions("v1.11.0", "2b44b074cf41439325ce4d0bbdac2d51379f56faf17ba15320a410d3c1f07275")
    add_versions("v1.10.0", "cf29873b894133bac111fc45bbf10989b6c5c041992fcd10e31222253e371a4c")
    add_versions("v1.9.0", "dff575df08d88583c109702c7c5c75ff6e51611e6eacca8b5b3fdfba8ecc2cb4")
    add_versions("v1.8.1", "a0d09371fadb56489497996b28433be1ef91a705e3811fcb1f50a107c7d427d1")
    add_versions("v1.8.0", "e184e63101cf19688a02102f58447acc7c021d77eef0d3475ceaceb61f035539")
    add_versions("v1.7.2", "5ff96c14ae19592d3568e9ae107624cbaf3409d328fb1a586359f0adf9b34bf7")
    add_versions("v1.7.1", "65c6f9fc2365ced42ee8eb2d209a0d3a7942cd59ff4bd20464e195c433f3a885")
    add_versions("v1.7.0", "d10175ad66e7f113ac5dc00c9d6650a620663a6884fbf2942d6eb7a3d854604f")
    add_versions("v1.5.3", "ce1a7d2f008e60cc69ab06f8b16831bd0fcd5f6002d3bbebae9d7a3513a1d01d")

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_includedirs("include", "include/highs")

    add_deps("cmake", "zlib >=1.2.3")

    on_install("windows|x64", "windows|x86", "linux", "macosx", "bsd", "mingw", "msys", "iphoneos", "cross", "wasm", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DCI=OFF", "-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("Highs_addCol", {includes = "highs/interfaces/highs_c_api.h"}))
    end)
