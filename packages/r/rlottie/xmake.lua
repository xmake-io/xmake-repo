package("rlottie")
    set_homepage("https://github.com/Samsung/rlottie")
    set_description("A platform independent standalone library that plays Lottie Animation. ")

    add_urls("https://github.com/Samsung/rlottie/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/Samsung/rlottie.git")

    add_versions("0.1", "319d640f094f747e09177df59ca498f0df80c779ba789eeb1fc35da5a1c93414")
    add_versions("0.2", "030ccbc270f144b4f3519fb3b86e20dd79fb48d5d55e57f950f12bab9b65216a")
    add_patches("0.2", path.join(os.scriptdir(), "patches", "0.2", "limit.diff"), "6dc1c00c6ccad770586ec9d84f24d6c35e35dd624df877a71bb5c7bcc32831e9")
    add_configs("module", {description = "Enable LOTTIE MODULE SUPPORT", default = true, type = "boolean"})
    add_configs("thread", {description = "Enable LOTTIE THREAD SUPPORT", default = true, type = "boolean"})
    add_configs("cache",  {description = "Enable LOTTIE CACHE SUPPORT", default = true, type = "boolean"})
    add_configs("ccache", {description = "Enable LOTTIE CCACHE SUPPORT", default = false, type = "boolean"})
    add_configs("asan",   {description = "Compile with asan", default = false, type = "boolean"})

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("freetype", {configs = {zlib = false}})
    add_deps("rapidjson ~1.1.0", "stb 2019.02.07")

    on_install("windows", "linux", "macosx", "android", "iphoneos", "watchos", "wasm", function (package)
        if package:plat("windows") and package:arch("arm.*") then
            package:add("defines", "_LITTLE_ENDIAN")
        end

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIB_INSTALL_DIR=" .. package:installdir("lib"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                table.insert(configs, "-DLOTTIE_" .. name:upper() .. "=" .. (enabled and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("rlottie::Surface", {includes = "rlottie.h"}))
    end)
