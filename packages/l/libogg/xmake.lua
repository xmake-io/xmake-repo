package("libogg")
    set_homepage("https://www.xiph.org/ogg/")
    set_description("Ogg Bitstream Library")
    set_license("BSD")

    add_urls("https://github.com/xiph/ogg/archive/refs/tags/$(version).tar.gz", {alias = "github"})
    add_urls("https://gitlab.xiph.org/xiph/ogg/-/archive/$(version)/ogg-$(version).tar.gz", {alias = "gitlab"})
    add_urls("https://gitlab.xiph.org/xiph/ogg.git",
             "https://github.com/xiph/ogg.git")

    add_versions("github:v1.3.6", "95b643da661155d79db9de2fca55daed3a8d491039829def246aacb3d9201c81")
    add_versions("github:v1.3.5", "f6f1b04cfa4e98b70ffe775d5e302d9c6b98541f05159af6de2d6617817ed7d6")
    add_versions("github:v1.3.4", "3da31a4eb31534b6f878914b7379b873c280e610649fe5c07935b3d137a828bc")

    add_versions("gitlab:v1.3.5", "769ed632a71bfa8bdd3439ac7c712b74e12affdaeae2852c6a859bbbba424e68")
    add_versions("gitlab:v1.3.4", "62cc64b9fd3cf57bde3a9033e94534ba34313d2bb9698029f623121a4e47bb9b")

    add_patches("v1.3.4", "patches/1.3.4/macos_fix.patch", "e12c41ad71206777f399c1048914e5e5a2fe44e18d0d50ebe9bedbfbe0624c35")

    add_deps("cmake")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libogg")
    elseif is_plat("linux") then
        add_extsources("pacman::libogg", "apt::libogg-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::libogg")
    end

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ogg_sync_init", {includes = {"stdint.h", "ogg/ogg.h"}}))
    end)
