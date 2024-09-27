package("cnl")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/johnmcfarlane/cnl")
    set_description("A Compositional Numeric Library for C++")
    set_license("BSL-1.0")

    add_urls("https://github.com/johnmcfarlane/cnl.git")

    add_versions("2023.12.23", "7b6172f3d657147964079e91d078302d853419c5")

    add_deps("cmake")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) > 22, "package(cnl) require ndk version > 22")
        end)
    end

    on_install(function (package)
        io.replace("CMakeLists.txt", [[add_subdirectory("test")]], "", {plain = true})

        import("package.tools.cmake").install(package, {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release")
        })
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("cnl/all.h", {configs = {languages = "c++20"}}))
    end)
