package("clip")
    set_homepage("https://github.com/dacap/clip")
    set_description("Library to copy/retrieve content to/from the clipboard/pasteboard.")
    set_license("MIT")

    set_urls("https://github.com/dacap/clip/archive/refs/tags/v$(version).zip")
    add_versions("1.5", "4ed7f54184c27c79a8f2382ba747dce11aeb4552017abf5588587369a6caeb6b")

    add_deps("cmake", "libpng")
    if is_plat("linux") then
        add_deps("libxcb")
    elseif is_plat("windows") or is_plat("mingw") then
        add_syslinks("Shlwapi", "Ole32", "User32")
    end
    if is_plat("mingw") then
        add_syslinks("Windowscodecs")
    end

    add_includedirs("include")

    on_install("linux", "windows", "mingw@windows,msys", "macos", function(package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCLIP_EXAMPLES=OFF")
        table.insert(configs, "-DCLIP_TESTS=OFF")
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs, { buildir="build" })
        os.cp("clip.h", package:installdir("include/clip"))
        os.trycp("build/*.a", package:installdir("lib"))
        os.trycp("build/*.dylib", package:installdir("lib"))
        os.trycp("build/*.so", package:installdir("lib"))
        os.trycp("build/*.lib", package:installdir("lib"))
        os.trycp("build/*.dll", package:installdir("bin"))
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({ test = [[
              #include <clip/clip.h>
              #include <string>
              void test() { clip::set_text("foo"); }
          ]]}
        ))
    end)
