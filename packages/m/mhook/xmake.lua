package("mhook")

    set_homepage("https://github.com/martona/mhook")
    set_description("A Windows API hooking library ")

    set_urls("https://github.com/apriorit/mhook/archive/$(version).zip",
             "https://github.com/apriorit/mhook.git")

    add_versions("2.5.1", "37e7d65422a770b0a28835b4fe557823278f7118ff4a399d7acf345c8db318e5")

    add_patches("2.5.1", "https://github.com/apriorit/mhook/commit/5ccb00a9c89280bfff7ce595873a9923415172a7.patch",
                        "56561718ccf05c8c42fff05e6531cfa525cf93e0c9fa3bd226e74ef19eae1a1f")

    add_deps("cmake")

    on_install("windows", function (package)
        local configs = {}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("Mhook_SetHookEx", {includes = {"windows.h", "mhook-lib/mhook.h"}}))
    end)
