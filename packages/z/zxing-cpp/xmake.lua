package("zxing-cpp")
    set_homepage("https://github.com/zxing-cpp/zxing-cpp")
    set_description("C++ port of ZXing")
    set_license("Apache-2.0")

    add_urls("https://github.com/zxing-cpp/zxing-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zxing-cpp/zxing-cpp.git", {submodules = false})

    add_versions("v3.1.1", "7286b1e6ade66fe82b7c8208b4595deeb55d6486b410834fdc65702f46650542")
    add_versions("v3.0.2", "b063dacf384c7bb93ab2c3eea247cc06b4525330f0efa631907aa3029f7e2144")
    add_versions("v2.3.0", "64e4139103fdbc57752698ee15b5f0b0f7af9a0331ecbdc492047e0772c417ba")
    add_versions("v2.2.1", "02078ae15f19f9d423a441f205b1d1bee32349ddda7467e2c84e8f08876f8635")

    add_configs("reader", {description = "Build with reader support (decoders)", default = true, type = "boolean"})
    -- Build old and new (require zint) encoder
    add_configs("writer", {description = "Build with old and/or new writer (encoder) backend", default = true, type = "boolean"})
    add_configs("c_api", {description = "Build C API", default = false, type = "boolean"})
    add_configs("experimental", {description = "Build with experimental API", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            local version = package:version()
            if package:is_plat("android") and version and version:ge("3.0.2") then
                local ndk = package:toolchain("ndk"):config("ndkver")
                assert(ndk and tonumber(ndk) > 22, "package(zxing-cpp >=3.0.2) require ndk version > 22")
            end
            if version and version:ge("3.1.0") then
                if not package:check_cxxsnippets({test = [[
                    #include <memory>
                    void test(int* ptr) {
                        std::construct_at(ptr, 0);
                    }
                ]]}, {configs = {languages = "c++20"}}) then
                    raise("package(zxing-cpp >=3.1.0) unsupported current platform: std::construct_at is unavailable")
                end
            end
        end)
    end

    on_load(function (package)
        if package:config("c_api") or package:config("writer") then
            if is_subhost("windows") then
                package:add("deps", "pkgconf")
            else
                package:add("deps", "pkg-config")
            end

            if package:config("c_api") then
                package:add("deps", "stb")
            end
            if package:config("writer") then
                package:add("deps", "zint")
            end
        end
    end)

    on_install(function (package)
        if package:version() and package:version():ge("3.0.2") then
            io.replace("core/src/CreateBarcode.cpp",
                "std::make_unique<Data>(format, std::move(options))",
                "std::make_unique<Data>(Data{format, std::move(options)})", {plain = true})
        end

        local zint = package:dep("zint")
        if zint then
            if not zint:config("shared") then
                io.replace("core/CMakeLists.txt",
                    "target_link_libraries (ZXing PRIVATE zint)",
                    "target_link_libraries (ZXing PRIVATE zint::zint-static)", {plain = true})
            end
        end

        local configs = {
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_C_API=OFF",
            "-DBUILD_DEPENDENCIES=LOCAL",
            -- >=2.3.0
            "-DZXING_USE_BUNDLED_ZINT=OFF",
            "-DZXING_EXAMPLES=OFF",
            "-DZXING_DEPENDENCIES=LOCAL",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DZXING_READERS=" .. (package:config("reader") and "ON" or "OFF"))
        table.insert(configs, "-DZXING_WRITERS=" .. (package:config("writer") and "BOTH" or "OFF"))
        table.insert(configs, "-DBUILD_EXPERIMENTAL_API=" .. (package:config("experimental") and "ON" or "OFF"))
        table.insert(configs, "-DZXING_EXPERIMENTAL_API=" .. (package:config("experimental") and "ON" or "OFF"))
        table.insert(configs, "-DZXING_C_API=" .. (package:config("c_api") and "ON" or "OFF"))
        if zint then
            table.insert(configs, "-DZINT_STATIC=" .. (zint:config("shared") and "OFF" or "ON"))
        end

        local opt = {cxflags = {}, cxxflags = {}}
        if package:has_tool("cxx", "cl") then
            table.insert(opt.cxflags, "/utf-8")
        end
        if package:version() and package:version():ge("3.0.2") and
            package:is_plat("mingw") and package:has_tool("cxx", "gcc", "gxx") then
            -- https://gcc.gnu.org/bugzilla/show_bug.cgi?id=125359
            -- Avoid unresolved C4 constructor symbols emitted by GCC with upstream's per-file -Os flags.
            table.insert(opt.cxxflags, "-fno-declone-ctor-dtor")
        end
        if package:version() and package:version():le("2.3.0") and not package:is_debug() then
            -- https://github.com/zxing-cpp/zxing-cpp/issues/900
            table.insert(opt.cxflags, "-DNDEBUG")
        end
        import("package.tools.cmake").install(package, configs, opt)

        if package:version() and package:version():lt("2.3.0") then
            if package:config("c_api") then
                io.writefile("xmake.lua", [[
                    add_rules("mode.debug", "mode.release")
                    set_languages("c++17")
                    target("ZXing-c")
                        set_kind("$(kind)")
                        add_files("wrappers/c/zxing-c.cpp")
                        add_headerfiles("wrappers/c/zxing-c.h", {prefixdir = "ZXing"})
                        add_includedirs("core/src")
                        if is_plat("windows") and is_kind("shared") then
                            add_rules("utils.symbols.export_all", {export_classes = true})
                        end
                ]])
                import("package.tools.xmake").install(package)
            end
        end
    end)

    on_test(function (package)
        local languages = package:version() and package:version():ge("3.1.0") and "c++20" or "c++17"
        assert(package:check_cxxsnippets({test = [[
            #include <ZXing/ReadBarcode.h>
            void test() {
                int width, height;
                unsigned char* data;
                auto image = ZXing::ImageView(data, width, height, ZXing::ImageFormat::Lum);
            }
        ]]}, {configs = {languages = languages}}))
        if package:version() and package:version():ge("3.0.2") then
            assert(package:check_cxxsnippets({test = [[
                #include <ZXing/Barcode.h>
                void test() {
                    ZXing::Barcode barcode;
                    (void)barcode.isValid();
                }
            ]]}, {configs = {languages = languages}}))
        end

        if package:config("c_api") then
            if package:version() and package:version():ge("2.3.0") then
                assert(package:has_cfuncs("ZXing_ImageView_new", {includes = "ZXing/ZXingC.h"}))
            else
                assert(package:has_cfuncs("zxing_ImageView_new", {includes = "ZXing/zxing-c.h"}))
            end
        end
    end)
