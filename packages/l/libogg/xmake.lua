package("libogg")

    set_homepage("https://www.xiph.org/ogg/")
    set_description("Ogg Bitstream Library")

    set_urls("https://gitlab.xiph.org/xiph/ogg/-/archive/$(version)/ogg-$(version).tar.gz",
             "https://gitlab.xiph.org/xiph/ogg.git")
    add_versions("v1.3.4", "62cc64b9fd3cf57bde3a9033e94534ba34313d2bb9698029f623121a4e47bb9b")
    add_patches("v1.3.4", path.join(os.scriptdir(), "patches", "1.3.4", "macos_fix.patch"), "e12c41ad71206777f399c1048914e5e5a2fe44e18d0d50ebe9bedbfbe0624c35")

    add_deps("cmake")
    if is_plat("cross") and is_subhost("windows") then
        add_deps("make")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::libogg")
    elseif is_plat("linux") then
        add_extsources("pacman::libogg", "apt::libogg-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::libogg")
    end

    on_install("windows", "macosx", "linux", "mingw", "iphoneos", "android", "cross", "wasm", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ogg_sync_init", {includes = {"stdint.h", "ogg/ogg.h"}}))
    end)
