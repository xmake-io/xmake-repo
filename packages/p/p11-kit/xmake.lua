package("p11-kit")
    set_homepage("https://p11-glue.github.io/p11-glue/p11-kit.html")
    set_description("Provides a way to load and enumerate PKCS#11 modules.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/p11-glue/p11-kit/releases/download/$(version)/p11-kit-$(version).tar.xz",
             "https://github.com/p11-glue/p11-kit.git")

    add_versions("0.25.10", "a62a137a966fb3a9bbfa670b4422161e369ddea216be51425e3be0ab2096e408")
    add_versions("0.25.9", "98a96f6602a70206f8073deb5e894b1c8efd76ef53c629ab88815d58273f2561")
    add_versions("0.25.8", "2fd4073ee2a47edafaae2c8affa2bcca64e0697f8881f68f580801ef43cab0ce")
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

    add_includedirs("include/p11-kit-1")
    on_load(function (package)
        if package:is_cross() then
            package:add("deps", "libtasn1~host", {host = true, private = true})
        else
            package:addenv("PATH", "bin")
        end
    end)

    on_install("linux", "mingw", "macosx", "iphoneos", "bsd", "cross", function (package)
        local configs = {
            "-Dsystemd=disabled", 
            "-Dbash_completion=disabled",
            "-Dman=false",
            "-Dnls=false",
            "-Dtest=false"
        }
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test(CK_FUNCTION_LIST_PTR_PTR modules) {
                p11_kit_modules_finalize(modules);
                p11_kit_modules_release(modules);
            }
        ]]}, {includes = "p11-kit/p11-kit.h"}))
    end)
