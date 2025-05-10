package("woff2")
    set_homepage("https://github.com/google/woff2")
    set_description("Font compression reference code.")
    set_license("MIT")

    add_urls("https://github.com/google/woff2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/woff2.git", {submodules = false})

    add_versions("v1.0.2", "add272bb09e6384a4833ffca4896350fdb16e0ca22df68c0384773c67a175594")

    add_patches("v1.0.2", path.join(os.scriptdir(), "patches", "missing-gcc15-header.diff"), "357213b88875a61af3f83d1082129a59e6caa1ea6c25e272543d2875a1abadf4")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    if is_plat("cross", "linux", "mingw") then
        add_deps("brotli", {configs = {shared = true}})
    else
        add_deps("brotli")
    end

    on_check("mingw", function (package)
        if is_subhost("macosx") then
            raise("package(woff2) is unsupported on Mac OS X subhost.")
        end
    end)

    on_install(function (package)
        local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = {"brotli", "brotlienc", "brotlidec"}})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <woff2/output.h>
            void test() {
                uint8_t *ttf = new uint8_t[1024];
                woff2::WOFF2MemoryOut out(ttf, 1024);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
