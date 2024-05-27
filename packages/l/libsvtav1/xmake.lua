package("libsvtav1")
    set_homepage("https://gitlab.com/AOMediaCodec/SVT-AV1")
    set_description("An AV1-compliant software encoder/decoder library")
    set_license("BSD-3-Clause")

    add_urls("https://gitlab.com/AOMediaCodec/SVT-AV1/-/archive/$(version)/SVT-AV1-$(version).tar.gz",
             "https://gitlab.com/AOMediaCodec/SVT-AV1.git")

    add_versions("v2.1.0", "72a076807544f3b269518ab11656f77358284da7782cece497781ab64ed4cb8a")
    
    add_configs("encoder", {description = "Enable encoder", default = true, type = "boolean"})
    add_configs("decoder", {description = "Enable decoder", default = true, type = "boolean"})
    add_configs("minimal_build", {description = "Enable minimal build", default = false, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::svt-av1")
    elseif is_plat("linux") then
        add_extsources("pacman::svt-av1", "apt::libsvtav1-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::svt-av1")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl", "m")
    end

    add_deps("cmake", "nasm")
    add_deps("cpuinfo")

    on_install("!cross and !windows@arm.*", function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "EB_DLL")
        end

        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_APPS=OFF", "-DUSE_EXTERNAL_CPUINFO=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSVT_AV1_LTO=" .. (package:config("lto") and "ON" or "OFF"))

        table.insert(configs, "-DBUILD_ENC=" .. (package:config("encoder") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_DEC=" .. (package:config("decoder") and "ON" or "OFF"))
        table.insert(configs, "-DMINIMAL_BUILD=" .. (package:config("minimal_build") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:config("encoder") then
            assert(package:has_cfuncs("svt_av1_enc_init_handle", {includes = {"stddef.h", "svt-av1/EbSvtAv1Enc.h"}}))
        end
        if package:config("decoder") then
            assert(package:has_cfuncs("svt_av1_dec_init_handle", {includes = {"stddef.h", "svt-av1/EbSvtAv1Dec.h"}}))
        end
    end)
