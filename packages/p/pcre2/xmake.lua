package("pcre2")
    set_homepage("https://www.pcre.org/")
    set_description("A Perl Compatible Regular Expressions Library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/PhilipHazel/pcre2/releases/download/pcre2-$(version)/pcre2-$(version).tar.gz",
             "https://github.com/PhilipHazel/pcre2.git")

    add_versions("10.44", "86b9cb0aa3bcb7994faa88018292bc704cdbb708e785f7c74352ff6ea7d3175b")
    add_versions("10.43", "889d16be5abb8d05400b33c25e151638b8d4bac0e2d9c76e9d6923118ae8a34e")
    add_versions("10.42", "c33b418e3b936ee3153de2c61cc638e7e4fe3156022a5c77d0711bcbb9d64f1f")
    add_versions("10.40", "ded42661cab30ada2e72ebff9e725e745b4b16ce831993635136f2ef86177724")
    add_versions("10.39", "0781bd2536ef5279b1943471fdcdbd9961a2845e1d2c9ad849b9bd98ba1a9bd4")

    if not is_plat("iphoneos") then
        add_configs("jit", {description = "Enable jit.", default = not is_plat("wasm"), type = "boolean"})
    end
    add_configs("bitwidth", {description = "Set the code unit width.", default = "8", values = {"8", "16", "32"}})

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            if package:is_arch("armeabi-v7a") then
                local ndk = package:toolchain("ndk")
                local ndkver = ndk:config("ndkver")
                assert(ndkver and tonumber(ndkver) > 22, "package(pcre2/armeabi-v7a): need ndk version > 22")
            end
        end)
    end

    on_load(function (package)
        local bitwidth = package:config("bitwidth") or "8"
        local suffix = ""
        if package:is_plat("windows") and package:is_debug() then
            suffix = "d"
        end
        package:add("links", "pcre2-posix" .. suffix)
        package:add("links", "pcre2-" .. bitwidth .. suffix)
        package:add("defines", "PCRE2_CODE_UNIT_WIDTH=" .. bitwidth)
        if not package:config("shared") then
            package:add("defines", "PCRE2_STATIC")
        end
    end)

    on_install(function (package)
        if package:gitref() or package:version():lt("10.21") then
            io.replace("CMakeLists.txt", [[SET(CMAKE_C_FLAGS -I${PROJECT_SOURCE_DIR}/src)]], [[SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -I${PROJECT_SOURCE_DIR}/src")]], {plain = true})
        end
        io.replace("CMakeLists.txt", "OUTPUT_NAME pcre2%-(%w-)%-static", "OUTPUT_NAME pcre2-%1")

        local configs = {"-DPCRE2_BUILD_TESTS=OFF", "-DPCRE2_BUILD_PCRE2GREP=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DPCRE2_SUPPORT_JIT=" .. (package:config("jit") and "ON" or "OFF"))
        table.insert(configs, "-DPCRE2_STATIC_PIC=" .. (package:config("pic") and "ON" or "OFF"))

        local bitwidth = package:config("bitwidth") or "8"
        if bitwidth ~= "8" then
            table.insert(configs, "-DPCRE2_BUILD_PCRE2_8=OFF")
            table.insert(configs, "-DPCRE2_BUILD_PCRE2_" .. bitwidth .. "=ON")
        end
        if package:is_debug() then
            table.insert(configs, "-DPCRE2_DEBUG=ON")
            table.insert(configs, "-DINSTALL_MSVC_PDB=ON")
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DPCRE2_STATIC_RUNTIME=" .. (package:has_runtime("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)

        local defines = table.wrap(package:get("defines"))
        if defines and #defines ~= 0 then
            defines = table.clone(defines)
            for i, define in ipairs(defines) do
                defines[i] = "-D" .. define
            end
            table.insert(defines, 1, "Cflags: -I${includedir}")
            local pkgconfig_dir = package:installdir("lib/pkgconfig")

            local pcre2_pc = path.join(pkgconfig_dir, format("libpcre2-%d.pc", package:config("bitwidth")))
            io.replace(pcre2_pc, "Cflags: -I${includedir}", table.concat(defines, " "), {plain = true})

            local pcre2_posix_pc = path.join(pkgconfig_dir, "libpcre2-posix.pc")
            if os.isfile(pcre2_posix_pc) then
                io.replace(pcre2_posix_pc, "Cflags: -I${includedir}", table.concat(defines, " "), {plain = true})
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pcre2_compile", {includes = "pcre2.h"}))
    end)
