package("ffts")
    set_homepage("http://anthonix.com/ffts")
    set_description("The Fastest Fourier Transform in the South")

    add_urls("https://github.com/linkotec/ffts.git")
    add_versions("2019.03.19", "2c8da4877588e288ff4cd550f14bec2dc7bf668c")

    add_configs("neon", {description = "Enables the use of NEON instructions.", default = false, type = "boolean"})
    add_configs("vfp", {description = "Enables the use of VFP instructions.", default = false, type = "boolean"})

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            if package:has_tool("cc", "clang", "clang_cl") then
                raise("package(ffts) unsupported clang toolchain")
            end
        end)
    end

    on_install(function (package)
        -- remove test
        io.replace("CMakeLists.txt", "endif(ENABLE_STATIC OR ENABLE_SHARED)", "endif(0)", {plain = true})
        io.replace("CMakeLists.txt", "if(ENABLE_STATIC OR ENABLE_SHARED)", "if(0)", {plain = true})
        io.replace("CMakeLists.txt",
            "install( TARGETS ffts_shared DESTINATION ${LIB_INSTALL_DIR} )",
            [[install(TARGETS ffts_shared
                RUNTIME DESTINATION bin
                LIBRARY DESTINATION lib
                ARCHIVE DESTINATION lib
            )
            ]], {plain = true})

        if package:is_plat("android") then
            io.replace("src/ffts.c", "cacheflush((long) start, (long) start + length, 0);", [[
                #if defined(__arm__) || defined(__aarch64__)
                    int cacheflush(long __addr, long __nbytes, long __cache);
                    cacheflush((long) start, (long) start + length, 0);
                #endif
            ]], {plain = true})
        end

        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "FFTS_SHARED")
        end

        local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DCMAKE_CROSSCOMPILING=" .. (package:is_cross() and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_NEON=" .. (package:config("neon") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_VFP=" .. (package:config("vfp") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.trycp(path.join(package:buildir(), "fftsd.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ffts_execute", {includes = "ffts/ffts.h"}))
    end)
