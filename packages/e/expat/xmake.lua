package("expat")

    set_homepage("https://libexpat.github.io")
    set_description("XML 1.0 parser")
    set_license("MIT")

    set_urls("https://github.com/libexpat/libexpat/releases/download/R_$(version).tar.bz2", {version = function (version) return version:gsub("%.", "_") .. "/expat-" .. version end})
    add_versions("2.5.0", "6f0e6e01f7b30025fa05c85fdad1e5d0ec7fd35d9f61b22f34998de11969ff67")
    add_versions("2.4.8", "a247a7f6bbb21cf2ca81ea4cbb916bfb9717ca523631675f99b3d4a5678dcd16")
    add_versions("2.4.7", "e149bdd8b90254c62b3d195da53a09bd531a4d63a963b0d8a5268d48dd2f6a65")
    add_versions("2.4.5", "fbb430f964c7a2db2626452b6769e6a8d5d23593a453ccbc21701b74deabedff")
    add_versions("2.4.1", "2f9b6a580b94577b150a7d5617ad4643a4301a6616ff459307df3e225bcfbf40")
    add_versions("2.3.0", "f122a20eada303f904d5e0513326c5b821248f2d4d2afbf5c6f1339e511c0586")
    add_versions("2.2.10", "b2c160f1b60e92da69de8e12333096aeb0c3bf692d41c60794de278af72135a5")
    add_versions("2.2.6", "17b43c2716d521369f82fc2dc70f359860e90fa440bea65b3b85f0b246ea81f2")

    add_deps("cmake")
    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "XML_STATIC")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", "cross", function (package)
        local configs = {"-DEXPAT_BUILD_EXAMPLES=OFF", "-DEXPAT_BUILD_TESTS=OFF", "-DEXPAT_BUILD_DOCS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DEXPAT_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DEXPAT_MSVC_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XML_ParserCreate(NULL)", {includes = "expat.h"}))
    end)
