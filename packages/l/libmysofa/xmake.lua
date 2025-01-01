package("libmysofa")
    set_homepage("https://github.com/hoene/libmysofa")
    set_description("Reader for AES SOFA files to get better HRTFs")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/hoene/libmysofa/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hoene/libmysofa.git")

    add_versions("v1.3.2", "6c5224562895977e87698a64cb7031361803d136057bba35ed4979b69ab4ba76")

    add_patches("v1.3.2", "patches/v1.3.2/fix-build.patch", "34308e9aab3700c2db1bcdc230fc9fbd399b8ff4a849fb94a86c99ebfb49a670")

    add_deps("cmake", "zlib")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install(function (package)
        if package:is_plat("wasm", "cross") then
            io.replace("src/CMakeLists.txt", [[find_library(MATH m)]], [[set(MATH "")]], {plain = true})
        end
        os.rm("windows/third-party/zlib-1.2.11")
        os.cp("share/MIT_KEMAR_normal_pinna.sofa", "share/default.sofa")
        local configs = {"-DBUILD_TESTS=OFF", "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mysofa_open", {includes = "mysofa.h"}))
    end)
