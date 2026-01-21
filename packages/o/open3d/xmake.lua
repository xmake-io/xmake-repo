package("open3d")

    set_homepage("http://www.open3d.org/")
    set_description("Open3D: A Modern Library for 3D Data Processing")
    set_license("MIT")

    add_urls("https://github.com/isl-org/Open3D/archive/refs/tags/$(version).tar.gz",
             "https://github.com/isl-org/Open3D.git")
    add_versions("v0.18.0", "524ddeb7dc8aaed6dc5b272415df0c8ffcf7eff0816a84cfbdee56cdd6d3587a")
    add_versions("v0.15.1", "4bcfbaa6fcbcc14fba46a4d719b9256fffac09b23f8344a7d561b26394159660")
    add_versions("v0.17.0", "a7526efaf54434c4d54276fa0ddc63a1555401c30fb10fec9efa3241326bdd27")

    add_configs("python", {description = "Build the python module.", default = false, type = "boolean"})
    add_configs("cuda",   {description = "Enable CUDA support.", default = false, type = "boolean"})
    add_configs("blas",   {description = "Choose BLAS vendor.", default = "mkl", type = "string", values = {"mkl", "openblas"}})

    add_deps("cmake", "nasm")
    add_deps("openssl", {system = false})
    add_includedirs("include", "include/open3d/3rdparty")
    if is_plat("linux") then
        add_syslinks("stdc++fs")
        add_deps("libx11", "libxrandr", "libxrender", "libxinerama", "libxcursor", "libxfixes", "libxext", "libxi")
    end
    on_load("windows|x64", "linux|x86_64", "macosx|x86_64", function (package)
        if package:config("cuda") then
            package:add("deps", "cuda")
        end
        if package:config("python") then
            package:add("deps", "python 3.x")
        else
            package:add("deps", "python 3.x", {kind = "binary"})
        end
        if package:config("blas") ~= "mkl" then
            package:add("deps", package:config("blas"))
        end
    end)

    on_install("windows|x64", "linux|x86_64", "macosx|x86_64", function (package)
        if package:is_plat("linux") and package:has_tool("cxx", "clang", "clangxx") then
            package:add("ldflags", "-fsanitize=safe-stack")
        end
        io.replace("CMakeLists.txt", "add_subdirectory(docs)", "", {plain = true})
        io.replace("CMakeLists.txt", "add_subdirectory(examples)", "", {plain = true})
        io.replace("3rdparty/curl/curl.cmake", "add_dependencies", "#", {plain = true})
        io.replace("3rdparty/find_dependencies.cmake", "OpenSSL::Crypto", "OpenSSL::SSL OpenSSL::Crypto", {plain = true})
        io.writefile("examples/test_data/download_file_list.json", "{}")
        local configs = {"-DCMAKE_FIND_FRAMEWORK=LAST",
                         "-DBUILD_EXAMPLES=OFF",
                         "-DBUILD_UNIT_TESTS=OFF",
                         "-DBUILD_BENCHMARKS=OFF",
                         "-DBUILD_ISPC_MODULE=OFF",
                         "-DBUILD_WEBRTC=OFF",
                         "-DUSE_SYSTEM_BLAS=ON",
                         "-DUSE_SYSTEM_OPENSSL=ON",
                         "-DBUILD_FILAMENT_FROM_SOURCE=OFF",
                         "-DBUILD_CURL_FROM_SOURCE=ON",
                         "-DWITH_IPPICV=OFF",
                         "-DGLIBCXX_USE_CXX11_ABI=ON",
                         "-DPREFER_OSX_HOMEBREW=OFF",
                         "-DDEVELOPER_BUILD=OFF"}
        if package:is_plat("windows") then
            local msvc = import("core.tool.toolchain").load("msvc")
            local vs = msvc:config("vs")
            local vstool
            if     vs == "2015" then vstool = "vc140"
            elseif vs == "2017" then vstool = "vc141"
            elseif vs == "2019" then vstool = "vc142"
            elseif vs == "2022" then vstool = "vc143"
            end
            assert(vstool, "unknown vs version: %s", vs)
            io.replace("3rdparty/assimp/assimp.cmake", "lib_name assimp%-vc.-%-mt", format("lib_name assimp-%s-mt", vstool))
            local vs_sdkver = msvc:config("vs_sdkver")
            if vs_sdkver then
                local build_ver = string.match(vs_sdkver, "%d+%.%d+%.(%d+)%.?%d*")
                assert(tonumber(build_ver) >= 18362, "open3d requires Windows SDK to be at least 10.0.18362.0")
                table.insert(configs, "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=" .. vs_sdkver)
                table.insert(configs, "-DCMAKE_SYSTEM_VERSION=" .. vs_sdkver)
            end
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_PYTHON_MODULE=" .. (package:config("python") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_CUDA_MODULE=" .. (package:config("cuda") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DSTATIC_WINDOWS_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        table.insert(configs, "-DUSE_BLAS=" .. (package:config("blas") == "openblas" and "ON" or "OFF"))
        table.insert(configs, "-DBORINGSSL_ROOT_DIR=" .. package:dep("openssl"):installdir())
        if package:is_plat("windows") then
            import("package.tools.cmake").install(package, configs, {buildir = os.tmpfile() .. ".dir"})
        elseif package:is_plat("linux") then
            import("package.tools.cmake").install(package, configs, {packagedeps = {"libxrandr", "libxrender", "libxinerama", "libxcursor", "libxfixes", "libxext", "libxi", "libx11"}})
        else
            import("package.tools.cmake").install(package, configs)
        end
        if not package:is_plat("windows") then
            package:add("links", "Open3D")
            for _, f in ipairs(os.files(path.join(package:installdir("lib"), "lib*.a"))) do
                if f:match(".+Open3D_3rdparty_.+%.a") then
                    package:add("links", path.basename(f):match("lib(.+)"))
                end
            end
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include <string>
            void test() {
                using namespace open3d::utility::filesystem;
                std::vector<std::string> filenames;
                ListFilesInDirectory(".", filenames);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "open3d/Open3D.h"}))
    end)
