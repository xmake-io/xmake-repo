package("blend2d")
    set_homepage("https://blend2d.com")
    set_description("2D Vector Graphics Engine Powered by a JIT Compiler")
    set_license("zlib")

    set_urls("https://blend2d.com/download/blend2d-$(version).tar.gz",
             "https://github.com/blend2d/blend2d.git")

    add_versions("0.11.1", "f46d61b6aa477fea1a353a41f5906d4e861817ae059ed22fc6ecdd50ff859dd2")

    add_configs("jit", {description = "Enable JIT compiler support", default = true, type = "boolean"})

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_check("windows", function (package)
        import("core.tool.toolchain")

        local msvc = toolchain.load("msvc", {plat = package:plat(), arch = package:arch()})
        if msvc and package:is_arch("arm.*") then
            local vs = msvc:config("vs")
            assert(vs and tonumber(vs) >= 2022, "package(blend2d/arm): need vs >= 2022")
        end
    end)

    on_load(function (package)
        if package:config("jit") then
            package:add("deps", "asmjit")
        end
        if not package:config("shared") then
            package:add("defines", "BL_STATIC")
        end
    end)

    on_install("!iphoneos", function (package)
        local configs = {}
        if package:config("jit") then
            table.insert(configs, "-DBLEND2D_EXTERNAL_ASMJIT=TRUE")
            table.insert(configs, "-DBLEND2D_NO_JIT=OFF")
        else
            table.insert(configs, "-DBLEND2D_NO_JIT=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBLEND2D_STATIC=" .. (package:config("shared") and "FALSE" or "TRUE"))

        local cxflags
        if package:is_plat("windows") and package:is_arch("arm.*") then
            cxflags = "-D__ARM_NEON"
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                BLImage img(480, 480, BL_FORMAT_PRGB32);
                BLContext ctx(img);
                ctx.setCompOp(BL_COMP_OP_SRC_COPY);
                ctx.fillAll();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "blend2d.h"}))
    end)
