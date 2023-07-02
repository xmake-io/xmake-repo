package("svt-av1")
    set_homepage("https://gitlab.com/AOMediaCodec/SVT-AV1")
    set_description("Scalable Video Technology for AV1 (SVT-AV1 Encoder and Decoder)")

    add_urls("https://gitlab.com/AOMediaCodec/SVT-AV1.git",
        "https://gitlab.com/AOMediaCodec/SVT-AV1/-/archive/v$(version)/SVT-AV1-v$(version).tar.gz")
    add_versions("1.4.0", "0a4650b822c4eeb9656fbe96bd795e7a73cbfd1ab8c12546348ba88d8ed6b415")
    add_versions("1.4.1", "e3f7fc194afc6c90b43e0b80fa24c09940cb03bea394e0e1f5d1ded18e9ab23f")
    add_versions("1.5.0", "64e27b024eb43e4ba4e7b85584e0497df534043b2ce494659532c585819d0333")
    add_versions("1.6.0", "3bc207247568ac713245063555082bfc905edc31df3bf6355e3b194cb73ad817")

    add_deps("cmake", "yasm", "libtool")
    add_syslinks("pthread")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIB_INSTALL_DIR=" .. package:installdir("lib"))
        if package:is_plat("wasm") then
            package:add("ldflags", "-fno-stack-protector")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("EbAv1PictureType", {includes = "svt-av1/EbSvtAv1.h"}))
    end)
