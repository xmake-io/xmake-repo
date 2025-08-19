package("libmysofa")
    set_homepage("https://github.com/hoene/libmysofa")
    set_description("Reader for AES SOFA files to get better HRTFs")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/hoene/libmysofa/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hoene/libmysofa.git")

    add_versions("v1.3.3", "a15f7236a2b492f8d8da69f6c71b5bde1ef1bac0ef428b94dfca1cabcb24c84f")
    add_versions("v1.3.2", "6c5224562895977e87698a64cb7031361803d136057bba35ed4979b69ab4ba76")

    add_patches("v1.3.2", "patches/v1.3.2/fix-build.patch", "a28aed4c5e766081ff90a7aed74c58b77927432a80385f6aad9f3278cde6bb59")

    add_deps("cmake", "zlib")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_install(function (package)
        if not package:config("shared") then
            package:add("defines", "MYSOFA_STATIC_DEFINE")
        end

        if package:version() and package:version():le("1.3.2") then
            io.replace("src/CMakeLists.txt", "${BUILD_SHARED_LIBS}", package:config("pic") and "ON" or "OFF", {plain = true})
        end
        if package:is_plat("wasm", "cross") then
            io.replace("src/CMakeLists.txt", [[find_library(MATH m)]], [[set(MATH "")]], {plain = true})
        end
        if is_host("windows") and package:is_plat("wasm") then
            io.replace("src/hrtf/portable_endian.h", [[elif defined(__WINDOWS__)]], [[elif 1]], {plain = true})
        end
        if is_host("linux") and package:is_plat("wasm") then
            io.replace("src/hrtf/portable_endian.h", [[if defined(__linux__)]], [[if 1]], {plain = true})
        end
        if is_host("bsd") and package:is_plat("wasm") then
            io.replace("src/hrtf/portable_endian.h", [[defined(__FreeBSD__)]], [[1]], {plain = true})
        end
        if is_host("macosx") and package:is_plat("wasm") then
            io.replace("src/hrtf/portable_endian.h", [[elif defined(__APPLE__)]], [[elif 1]], {plain = true})
        end
        os.rm("windows/third-party/zlib-1.2.11")
        os.rm("share/default.sofa")
        os.cp("share/MIT_KEMAR_normal_pinna.sofa", "share/default.sofa")

        local configs = {"-DBUILD_TESTS=OFF", "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DADDRESS_SANITIZE=" .. (package:config("asan") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mysofa_open", {includes = "mysofa.h"}))
    end)
