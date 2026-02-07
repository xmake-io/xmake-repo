package("gz-cmake")
    set_kind("binary")
    set_homepage("https://gazebosim.org/libs/cmake")
    set_description("A set of CMake modules that are used by the C++-based Gazebo projects.")
    set_license("Apache-2.0")

    add_urls("https://github.com/gazebosim/gz-cmake/archive/refs/tags/gz-cmake5_$(version).tar.gz")
    add_urls("https://github.com/gazebosim/gz-cmake.git", {alias = "git"})

    add_versions("5.0.1", "14ceed43715be67b52345a1696333322b1b4fcbd1335a33c9fc162460df8938a")

    add_versions("git:5.0.1", "gz-cmake5_5.0.1")

    add_deps("cmake")

    on_install(function (package)
        io.replace("cmake/GzPackaging.cmake", "include(InstallRequiredSystemLibraries)", "", {plain = true})
        -- fix ios build
        io.replace("cmake/GzSetCompilerFlags.cmake", "if(APPLE)", "if(APPLE AND NOT IOS)", {plain = true})
        -- Fix for x86 ARM RISC-V
        io.replace("CMakeLists.txt", "COMPATIBILITY SameMajorVersion)", "COMPATIBILITY SameMajorVersion\nARCH_INDEPENDENT)", {plain = true})
        import("package.tools.cmake").install(package, {"-DBUILD_TESTING=OFF"})
    end)

    on_test(function (package)
        assert(os.isfile(path.join(package:installdir(), "share/cmake/gz-cmake/gz-cmake-config.cmake")))
        if package.check_importfiles then
            package:check_importfiles("cmake::gz-cmake")
        end
    end)
