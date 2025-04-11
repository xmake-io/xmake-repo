package("p11-kit")
    set_homepage("https://p11-glue.github.io/p11-glue/p11-kit.html")
    set_description("Provides a way to load and enumerate PKCS#11 modules.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/p11-glue/p11-kit/releases/download/$(version)/p11-kit-$(version).tar.xz",
             "https://github.com/p11-glue/p11-kit.git")

    add_versions("0.25.5", "04d0a86450cdb1be018f26af6699857171a188ac6d5b8c90786a60854e1198e5")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::p11-kit")
    elseif is_plat("linux") then
        add_extsources("pacman::libp11-kit", "apt::libp11-kit-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::p11-kit")
    end

    add_deps("meson", "ninja")
    add_deps("libffi", "libtasn1")

    on_load(function (package)
        if package:is_cross() then
            package:add("deps", "libtasn1~host", {host = true, private = true})
        else
            package:addenv("PATH", "bin")
        end
    end)

    on_install("linux", "mingw", "macosx", "iphoneos", "bsd", "cross", function (package)
        local configs = {"-Dsystemd=disabled", "-Dbash_completion=disabled", "-Dtest=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
        os.trymv(package:installdir("include", "p11-kit-1", "*"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test(CK_FUNCTION_LIST_PTR_PTR modules) {
                p11_kit_modules_finalize(modules);
                p11_kit_modules_release(modules);
            }
        ]]}, {includes = "p11-kit/p11-kit.h"}))
    end)
