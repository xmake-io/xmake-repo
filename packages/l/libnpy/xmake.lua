package("libnpy")
    set_homepage("https://github.com/llohse/libnpy")
    set_description("C++ library for reading and writing of numpy's .npy files")
    set_license("MIT")

    add_urls("https://github.com/llohse/libnpy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/llohse/libnpy.git")

    add_versions("v1.5.3", "27f6ce7136fe9d4bc823b98585e21f5cd8c27b72d634afa9d613cd4101e6aff1")
    add_patches("v1.5.3", "patches/v1.5.3/fix.diff", "a1db18e4615ece28b6ef0c7e3befcca8bdd696191b983968843ba69213c1d77f")

    add_includedirs("include", "include/npy")

    add_deps("cmake")
    add_deps("miniz")

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
        assert(package:check_cxxsnippets({test = [[
            #include <tensor.h>
            #include <npy.h>
            #include <npz.h>
            void test() {
                std::vector<size_t> shape({65, 12, 8});
                npy::tensor<std::uint8_t> color(shape);
                npy::save("color.npy", color);
                npy::onpzstream output("test.npz");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
