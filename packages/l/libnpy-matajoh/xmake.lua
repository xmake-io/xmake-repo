package("libnpy-matajoh")
    set_homepage("https://github.com/matajoh/libnpy")
    set_description("C++ library for reading and writing of numpy's .npy files")
    set_license("MIT")

    add_urls("https://github.com/matajoh/libnpy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/matajoh/libnpy.git")

    add_versions("v2.1.0", "366f8e9dda31b08a8ef291f964f3bece7aede148dbde7836df08bf0397aee9c5")
    add_versions("v1.5.3", "27f6ce7136fe9d4bc823b98585e21f5cd8c27b72d634afa9d613cd4101e6aff1")

    add_patches("v2.1.0", "patches/v2.1.0/fix-cmake.diff", "67d8bca8232a173e5a0e7bdef7361e9f9f5469a50679f475a4798b7c6a8884f7")
    add_patches("v1.5.3", "patches/v1.5.3/fix.diff", "a1db18e4615ece28b6ef0c7e3befcca8bdd696191b983968843ba69213c1d77f")

    add_includedirs("include", "include/npy")

    add_deps("cmake")
    add_deps("miniz")

    on_load(function (package)
        if package:is_plat("android") then
            local ndk = package:toolchain("ndk")
            local ndkver = ndk and ndk:config("ndkver")
            if ndkver and tonumber(ndkver) == 27 then
                package:add("patches", "v2.1.0", "patches/v2.1.0/fix-r27.diff", "3c2144fd9d591e137722f72992a341c0cd33dfddee32348edb7d629da5d4e5db")
            end
        end
    end)

    on_install(function (package)
        os.rm("doc", "src/miniz")
        local configs = {}
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:gitref() or (package:version() and package:version():ge("2.0.0")) then
            assert(package:check_cxxsnippets({test = [[
                #include <npy/npy.h>
                void test() {
                    std::vector<size_t> shape({65, 12, 8});
                    npy::tensor<std::uint8_t> color(shape);
                    npy::save("color.npy", color);
                    npy::npzfilewriter output("test.npz");
                    output.write("color", color);
                    output.close();
                }
            ]]}, {configs = {languages = "c++17"}}))
        else
            assert(package:check_cxxsnippets({test = [[
                #include <npy/tensor.h>
                #include <npy/npy.h>
                #include <npy/npz.h>
                void test() {
                    std::vector<size_t> shape({65, 12, 8});
                    npy::tensor<std::uint8_t> color(shape);
                    npy::save("color.npy", color);
                    npy::onpzstream output("test.npz");
                }
            ]]}, {configs = {languages = "c++17"}}))
        end
    end)
