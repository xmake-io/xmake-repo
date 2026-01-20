package("hdf5")
    set_homepage("https://www.hdfgroup.org/solutions/hdf5/")
    set_description("High-performance data management and storage suite")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/HDFGroup/hdf5.git")
    add_urls("https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-$(version).tar.gz", {version = function (version)
        return format("%d.%d/hdf5-%s/src/hdf5-%s", version:major(), version:minor(), version, version)
    end, alias = "home"})
    add_urls("https://github.com/HDFGroup/hdf5/releases/download/hdf5_$(version).tar.gz", {version = function (version)
        return format("%s/hdf5-%s", version:gsub("%-", "."), version)
    end, alias = "github"})

    add_versions("home:1.10.7", "7a1a0a54371275ce2dfc5cd093775bb025c365846512961e7e5ceaecb437ef15")
    add_versions("home:1.12.0", "a62dcb276658cb78e6795dd29bf926ed7a9bc4edf6e77025cd2c689a8f97c17a")
    add_versions("home:1.12.1", "79c66ff67e666665369396e9c90b32e238e501f345afd2234186bfb8331081ca")
    add_versions("home:1.12.2", "2a89af03d56ce7502dcae18232c241281ad1773561ec00c0f0e8ee2463910f14")
    add_versions("home:1.13.2", "01643fa5b37dba7be7c4db6bbf3c5d07adf5c1fa17dbfaaa632a279b1b2f06da")
    add_versions("home:1.13.3", "83c7c06671f975cee6944b0b217f95005faa55f79ea5532cf4ac268989866af4")
    add_versions("home:1.14.0", "a571cc83efda62e1a51a0a912dd916d01895801c5025af91669484a1575a6ef4")

    add_versions("github:1.14.4-3", "019ac451d9e1cf89c0482ba2a06f07a46166caf23f60fea5ef3c37724a318e03")
    add_versions("github:1.14.6", "e4defbac30f50d64e1556374aa49e574417c9e72c6b1de7a4ff88c4b1bea6e9b")

    add_patches(">1.14.4 <2.0", "patch/cmake.patch", "f1a3f6be6d1bf53a49d47b726107261f8dacf028428f9d1552fc307c03670015")

    add_configs("zlib", {description = "Enable Zlib Filters", default = false, type = "boolean"})
    add_configs("szip", {description = "Enable Szip Filters", default = false, type = "boolean"})
    add_configs("cpplib", {description = "Build HDF5 C++ Library", default = false, type = "boolean"})

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("shlwapi")
    elseif is_plat("linux") then
        add_syslinks("dl")
    end

    on_load(function (package)
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
        if package:config("szip") then
            package:add("deps", "szip")
        end

        local libs = {"hdf5_hl_cpp", "hdf5_cpp", "hdf5_hl", "hdf5_tools", "hdf5"}
        local prefix = (package:is_plat("windows") and not package:config("shared")) and "lib" or ""
        for _, lib in ipairs(libs) do
            package:add("links", prefix .. lib)
        end

        package:addenv("HDF5_ROOT", "cmake")
        package:addenv("PATH", "bin")
    end)

    on_install("windows", "macosx", "linux", "bsd", function (package)
        -- remove postfix
        if os.isfile("config/cmake/HDFMacros.cmake") then
            io.replace("config/cmake/HDFMacros.cmake", "if(NOT CMAKE_DEBUG_POSTFIX)", "if(0)", {plain = true})
        end
        if os.isfile("CMakeInstallation.cmake") then
            io.replace("CMakeInstallation.cmake", "include (InstallRequiredSystemLibraries)", "", {plain = true})
        end

        local configs = {
            "-DHDF5_GENERATE_HEADERS=OFF",
            "-DBUILD_TESTING=OFF",
            "-DHDF5_BUILD_EXAMPLES=OFF",
            "-DHDF_PACKAGE_NAMESPACE:STRING=hdf5::",
            "-DHDF5_MSVC_NAMING_CONVENTION=OFF",
            "-DCMAKE_DEBUG_POSTFIX:STRING=''",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DONLY_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DHDF5_BUILD_STATIC_TOOLS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DHDF5_BUILD_CPP_LIB=" .. (package:config("cpplib") and "ON" or "OFF"))
        table.insert(configs, "-DHDF5_ENABLE_Z_LIB_SUPPORT=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-DHDF5_ENABLE_SZIP_SUPPORT=" .. (package:config("szip") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if not package:is_cross() then
            if package:config("shared") and (package:version() and package:version():le("1.14.0")) then
                os.vrun("h5diff-shared --version")
            else
                os.vrun("h5diff --version")
            end
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
