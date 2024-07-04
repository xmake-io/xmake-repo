package("libtommath")
    set_homepage("https://www.libtom.net")
    set_description("LibTomMath is a free open source portable number theoretic multiple-precision integer library written entirely in C.")
    set_license("Unlicense")

    add_urls("https://github.com/libtom/libtommath/releases/download/v$(version)/ltm-$(version).tar.xz",
             "https://github.com/libtom/libtommath/releases/download/v$(version)/ltm-$(version).tar.xz",
             "https://github.com/libtom/libtommath.git")

    add_versions("1.3.0", "296272d93435991308eb73607600c034b558807a07e829e751142e65ccfa9d08")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libtommath")
    elseif is_plat("linux") then
        add_extsources("pacman::libtommath", "apt::libtommath-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::libtommath")
    end

    add_deps("cmake")

    add_includedirs("include", "include/libtommath")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCOMPILE_LTO =" .. (package:config("lto") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs)
        os.trymv(package:installdir("include/*.h"), package:installdir("include/libtommath"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mp_init", {includes = "tommath.h"}))
        assert(package:has_cfuncs("mp_init", {includes = "libtommath/tommath.h"}))
    end)
