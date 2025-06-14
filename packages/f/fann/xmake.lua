package("fann")
    set_homepage("https://github.com/libfann/fann")
    set_description("Official github repository for Fast Artificial Neural Network Library (FANN)")
    set_license("LGPL-2.1")

    add_urls("https://github.com/libfann/fann.git")

    add_versions("2024.04.16", "1783cbf6239a597c4d29f694e227e22b8d4f4bf6")
    add_versions("2021.03.14", "a3cd24e528d6a865915a4fed6e8fac164ff8bfdc")

    add_patches("2024.04.16", "patches/2024.04.16/fix-install.diff", "61da5085b942221f7b35419416bb506efd398ae83ba58b738a57de0bb5df1bdc")

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_load(function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "FANN_NO_DLL")
        end
        if package:is_plat("mingw", "msys") and not is_subhost("macosx") then
            package:add("ldflags", "-fopenmp")
        end
        if package:is_plat("windows", "macosx") then
            package:add("deps", "openmp")
        elseif package:is_plat("macosx", "linux", "cross", "android", "mingw", "msys", "bsd") then
            if package:is_plat("android") then
                local ndk = package:toolchain("ndk")
                local ndk_sdkver = ndk:config("ndk_sdkver")
                if ndk_sdkver and tonumber(ndk_sdkver) > 25 then
                    package:add("deps", "libomp")
                end
            else
                package:add("deps", "libomp")
            end
        end
    end)

    on_install("windows", "macosx", "linux", "cross", "android", "mingw", "msys", "bsd", function (package)
        if package:is_plat("windows") and package:check_sizeof("void*") == "4" then
            io.replace("src/include/fann.h", [[#define FANN_API __stdcall]], [[#define FANN_API]], {plain = true})
        end
        local configs = {"-DCMAKE_POLICY_DEFAULT_CMP0057=NEW"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        io.replace("CMakeLists.txt", "ADD_SUBDIRECTORY( tests )", "", {plain = true})
        io.replace("CMakeLists.txt", "ADD_SUBDIRECTORY( lib/googletest )", "", {plain = true})
        local opt = {}
        if package:is_plat("macosx") then
            opt.packagedeps = "libomp"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <fann.h>
            void test() {
                struct fann_train_data *train_data;
                fann_scale_train_data(train_data, -1, 1);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
