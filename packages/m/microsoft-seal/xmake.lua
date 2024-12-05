package("microsoft-seal")
    set_homepage("https://www.microsoft.com/en-us/research/group/cryptography-research/")
    set_description("Microsoft SEAL is an easy-to-use and powerful homomorphic encryption library.")
    set_license("MIT")

    add_urls("https://github.com/microsoft/SEAL/archive/refs/tags/$(version).tar.gz",
             "https://github.com/microsoft/SEAL.git")

    add_versions("v4.1.2", "acc2a1a127a85d1e1ffcca3ffd148f736e665df6d6b072df0e42fff64795a13c")

    add_configs("zlib", {description = "Enable zlib", default = false, type = "boolean"})
    add_configs("zstd", {description = "Enable zstd", default = false, type = "boolean"})
    add_configs("ms_gsl", {description = "Enable microsoft-gsl", default = false, type = "boolean"})
    add_configs("hexl", {description = "Enable Intel HEXL", default = false, type = "boolean"})
    add_configs("throw_tran", {description = "Throw an exception when Evaluator outputs a transparent ciphertext", default = false, type = "boolean"})
    add_configs("gaussian", {description = "Use a rounded Gaussian distribution for noise sampling instead of a Centered Binomial Distribution", default = false, type = "boolean"})
    add_configs("intrin", {description = "Use intrinsics", default = false, type = "boolean"})
    add_configs("c_api",  {description = "Builds C API", default = false, type = "boolean", readonly = true})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("windows", "mingw") then
        add_syslinks("bcrypt")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("zstd") then
            package:add("deps", "zstd")
        end
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
        if package:config("ms_gsl") then
            package:add("deps", "microsoft-gsl")
        end
        if package:config("hexl") then
            package:add("deps", "hexl")
        end

        local version = package:version()
        if version then
            package:add("includedirs", format("include/SEAL-%s.%s", version:major(), version:minor()))
        else
            package:add("includedirs", "include/SEAL-4.1")
        end
    end)

    -- TODO: Fix cmake try_run
    on_install("!iphoneos", function (package)
        io.replace("CMakeLists.txt", "if(WIN32 AND BUILD_SHARED_LIBS)", "if(0)", {plain = true})
        if package:config("hexl") then
            io.replace("CMakeLists.txt", "1.2.4", "", {plain = true})
        end
        if package:is_plat("windows", "mingw") then
            io.replace("cmake/SEALMacros.cmake", "target_link_libraries(${target} PUBLIC Threads::Threads)",
                "target_link_libraries(${target} PUBLIC Threads::Threads bcrypt)", {plain = true})
        end

        local configs = {"-DSEAL_BUILD_DEPS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        table.insert(configs, "-DSEAL_USE_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-DSEAL_USE_ZSTD=" .. (package:config("zstd") and "ON" or "OFF"))
        table.insert(configs, "-DSEAL_USE_MSGSL=" .. (package:config("ms_gsl") and "ON" or "OFF"))
        table.insert(configs, "-DSEAL_USE_INTEL_HEXL=" .. (package:config("hexl") and "ON" or "OFF"))
        table.insert(configs, "-DSEAL_THROW_ON_TRANSPARENT_CIPHERTEXT=" .. (package:config("throw_tran") and "ON" or "OFF"))
        table.insert(configs, "-DSEAL_USE_GAUSSIAN_NOISE=" .. (package:config("gaussian") and "ON" or "OFF"))
        table.insert(configs, "-DSEAL_BUILD_SEAL_C=" .. (package:config("c_api") and "ON" or "OFF"))
        table.insert(configs, "-DSEAL_USE_INTRIN=" .. (package:config("intrin") and "ON" or "OFF"))

        if package:is_plat("mingw") then
            -- No aligned malloc implementation on MinGW
            -- https://github.com/ebassi/graphene/issues/83
            table.insert(configs, "-DSEAL_USE_ALIGNED_ALLOC=OFF")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace seal;
            void test() {
                EncryptionParameters parms(scheme_type::bfv);
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"seal/seal.h"}}))
    end)
