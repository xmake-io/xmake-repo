package("cubeb")
    set_homepage("https://github.com/mozilla/cubeb")
    set_description("Cross platform audio library")
    set_license("ISC")

    add_urls("https://github.com/mozilla/cubeb.git")
    add_versions("2023.7.31", "b9af56cee792f17a466db7b3ac3382262782c6f1")

    add_configs("speex", {description = "Bundle the speex library", default = false, type = "boolean"})
    add_configs("lazy_load", {description = "Lazily load shared libraries", default = true, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_syslinks("user32", "winmm", "ole32", "avrt", "ksuser")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreAudio", "AudioToolbox")
    end

    add_deps("cmake")

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "android", "wasm", "cross", function (package)
        local configs =
        {
            "-DBUILD_TESTS=OFF",
            "-DBUILD_RUST_LIBS=OFF",
            "-DBUILD_TOOLS=OFF",
            "-DUSE_SANITIZERS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUNDLE_SPEEX=" .. (package:config("speex") and "ON" or "OFF"))
        table.insert(configs, "-DLAZY_LOAD_LIBS=" .. (package:config("lazy_load") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("cubeb_init", {includes = "cubeb/cubeb.h", configs = {languages = "c++17"}}))
    end)
