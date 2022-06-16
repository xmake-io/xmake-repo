package("hdf5")

    set_homepage("https://www.hdfgroup.org/solutions/hdf5/")
    set_description("High-performance data management and storage suite")
    set_license("BSD-3-Clause")

    add_urls("https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-$(version).tar.gz", {version = function (version)
        return format("%d.%d/hdf5-%s/src/hdf5-%s", version:major(), version:minor(), version, version)
    end})
    add_versions("1.12.0", "a62dcb276658cb78e6795dd29bf926ed7a9bc4edf6e77025cd2c689a8f97c17a")
    add_versions("1.12.1", "79c66ff67e666665369396e9c90b32e238e501f345afd2234186bfb8331081ca")

    add_configs("cpplib", {description = "Build HDF5 C++ Library", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("linux") then
        add_syslinks("dl")
    end
    on_install("windows", "macosx", "linux", function (package)
        local configs = {
            "-DHDF5_GENERATE_HEADERS=OFF",
            "-DBUILD_TESTING=OFF",
            "-DHDF5_BUILD_EXAMPLES=OFF",
            "-DHDF_PACKAGE_NAMESPACE:STRING=hdf5::",
            "-DHDF5_MSVC_NAMING_CONVENTION=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DONLY_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DHDF5_BUILD_CPP_LIB=" .. (package:config("cpplib") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        package:addenv("HDF5_ROOT", path.join(package:installdir("share"), "cmake"))
        package:addenv("PATH", package:installdir("bin"))
    end)

    on_test(function (package)
        if package:config("shared") then
            os.vrun("h5diff-shared --version")
        else
            os.vrun("h5diff --version")
        end
        assert(package:has_cfuncs("H5open", {includes = "H5public.h"}))

        if package:config("cpplib") then
             assert(package:check_cxxsnippets({test = [[
                void test() {
                    H5::H5Library::open();
                }
            ]]}, {configs = {languages = "c++17"}, includes = {"H5Cpp.h"}}))
        end
    end)
