package("blend2d")
    set_homepage("https://blend2d.com")
    set_description("2D Vector Graphics Engine Powered by a JIT Compiler")
    set_license("zlib")

    add_urls("https://github.com/blend2d/blend2d.git")
    add_versions("2022.05.12", "84987c5f76c1b8f271e8556a4b87bcab78094c70")

    add_deps("cmake")

    add_deps("asmjit")
    if is_plat("linux") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        package:add("deps", "asmjit", {configs = {shared = package:config("shared")}})
        if not package:config("shared") then
            package:add("defines", "BL_STATIC")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DBLEND2D_TEST=OFF", "-DBLEND2D_NO_STDCXX=1"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBLEND2D_STATIC=" .. (package:config("shared") and "FALSE" or "TRUE"))
        io.replace("CMakeLists.txt", 'include("${ASMJIT_DIR}/CMakeLists.txt")', "", {plain = true})
        import("package.tools.cmake").install(package, configs, {packagedeps = "asmjit"})
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
