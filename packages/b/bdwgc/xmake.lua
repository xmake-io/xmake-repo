package("bdwgc")
    set_homepage("https://www.hboehm.info/gc/")
    set_description("The Boehm-Demers-Weiser conservative C/C++ Garbage Collector (bdwgc, also known as bdw-gc, boehm-gc, libgc)")

    add_urls("https://github.com/ivmai/bdwgc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ivmai/bdwgc.git")

    add_versions("v8.2.12", "d09001f45dabf1c29a5df3e63020a4bab5ad4aad69137bb07100c717e2ecba0b")
    add_versions("v8.2.10", "5858a417ab3eaac2add0daf79cd29ddf248c9f648e6c08092b775dcbfcbe1edb")
    add_versions("v8.2.6", "3bfc2b1dd385bfb46d2dab029211a66249a309795b6893f4e00554904999e40a")
    add_versions("v8.2.4", "18e63ab1428bd52e691da107a6a56651c161210b11fbe22e2aa3c31f7fa00ca5")

    add_deps("cmake")
    add_deps("libatomic_ops")

    if on_check then
        on_check("android", function (package)
            if package:is_arch("armeabi-v7a") then
                local ndk = package:toolchain("ndk")
                local ndk_sdkver = ndk:config("ndk_sdkver")
                assert(ndk_sdkver and tonumber(ndk_sdkver) > 21, "package(bdwgc/armeabi-v7a): need ndk api level > 21")
            end
        end)
        on_check("mingw", function (target)
            if package:version() and package:version():eq("8.2.4") then
                raise("package(bdwgc 8.2.4) unsupported mingw")
            end
        end)
    end

    on_install("!wasm", function (package)
        local configs = {"-Denable_docs=OFF", "-Dwith_libatomic_ops=ON"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "libatomic_ops"})

        if package:is_plat("windows", "mingw", "cygwin") then
            package:add("defines", (package:config("shared") and "GC_DLL" or "GC_NOT_DLL"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("GC_init", {includes = "gc/gc.h"}))
    end)
