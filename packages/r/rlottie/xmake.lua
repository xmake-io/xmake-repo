package("rlottie")
    set_homepage("https://github.com/Samsung/rlottie")
    set_description("A platform independent standalone library that plays Lottie Animation. ")

    add_urls("https://github.com/Samsung/rlottie/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Samsung/rlottie.git")

    add_versions("v0.1", "319d640f094f747e09177df59ca498f0df80c779ba789eeb1fc35da5a1c93414")
    add_versions("v0.2", "030ccbc270f144b4f3519fb3b86e20dd79fb48d5d55e57f950f12bab9b65216a")

    add_configs("module", {description = "Enable LOTTIE MODULE SUPPORT", default = true, type = "boolean"})
    add_configs("thread", {description = "Enable LOTTIE THREAD SUPPORT", default = true, type = "boolean"})
    add_configs("cache",  {description = "Enable LOTTIE CACHE SUPPORT", default = true, type = "boolean"})
    add_configs("ccache", {description = "Enable LOTTIE CCACHE SUPPORT", default = false, type = "boolean"})
    add_configs("asan",   {description = "Compile with asan", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("freetype", {configs = {zlib = false}})
    add_deps("pixman", "rapidjson", "stb")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

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
