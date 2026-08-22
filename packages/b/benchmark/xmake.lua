package("benchmark")
    set_homepage("https://github.com/google/benchmark")
    set_description("A microbenchmark support library")
    set_license("Apache-2.0")

    add_urls("https://github.com/google/benchmark/archive/refs/tags/$(version).tar.gz",
             "https://github.com/google/benchmark.git")

    add_versions("v1.9.5", "9631341c82bac4a288bef951f8b26b41f69021794184ece969f8473977eaa340")
    add_versions("v1.9.4", "b334658edd35efcf06a99d9be21e4e93e092bd5f95074c1673d5c8705d95c104")
    add_versions("v1.9.3", "b94263b018042007eb53f79639f21ae47800808c73cf1b7df85622b6e2b1aa32")
    add_versions("v1.9.2", "409075176168dc46bbb81b74c1b4b6900385b5d16bfc181d678afb060d928bd3")
    add_versions("v1.9.1", "32131c08ee31eeff2c8968d7e874f3cb648034377dfc32a4c377fa8796d84981")
    add_versions("v1.9.0", "35a77f46cc782b16fac8d3b107fbfbb37dcd645f7c28eee19f3b8e0758b48994")
    add_versions("v1.8.5", "d26789a2b46d8808a48a4556ee58ccc7c497fcd4c0af9b90197674a81e04798a")
    add_versions("v1.8.4", "3e7059b6b11fb1bbe28e33e02519398ca94c1818874ebed18e504dc6f709be45")
    add_versions("v1.8.3", "6bc180a57d23d4d9515519f92b0c83d61b05b5bab188961f36ac7b06b0d9e9ce")
    add_versions("v1.8.0", "ea2e94c24ddf6594d15c711c06ccd4486434d9cf3eca954e2af8a20c88f9f172")
    add_versions("v1.7.1", "6430e4092653380d9dc4ccb45a1e2dc9259d581f4866dc0759713126056bc1d7")
    add_versions("v1.7.0", "3aff99169fa8bdee356eaa1f691e835a6e57b1efeadb8a0f9f228531158246ac")
    add_versions("v1.6.1", "6132883bc8c9b0df5375b16ab520fac1a85dc9e4cf5be59480448ece74b278d4")
    add_versions("v1.6.0", "1f71c72ce08d2c1310011ea6436b31e39ccab8c2db94186d26657d41747c85d6")
    add_versions("v1.5.6", "789f85b4810d13ff803834ea75999e41b326405d83d6a538baf01499eda96102")
    add_versions("v1.5.5", "3bff5f237c317ddfd8d5a9b96b3eede7c0802e799db520d38ce756a2a46a18a0")
    add_versions("v1.5.4", "e3adf8c98bb38a198822725c0fc6c0ae4711f16fbbf6aeb311d5ad11e5a081b5")
    add_versions("v1.5.3", "e4fbb85eec69e6668ad397ec71a3a3ab165903abe98a8327db920b94508f720e")
    add_versions("v1.5.2", "dccbdab796baa1043f04982147e67bb6e118fe610da2c65f88912d73987e700c")

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::benchmark")
    elseif is_plat("linux") then
        add_extsources("pacman::benchmark", "apt::libbenchmark-dev")
    elseif is_plat("macosx")then
        add_extsources("brew::google-benchmark")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("windows", "mingw") then
        add_syslinks("shlwapi")
    end

    add_configs("exceptions", {description = "Enable exception", default = true, type = "boolean"})

    add_deps("cmake")
    add_links("benchmark_main", "benchmark")

    if on_check then
        on_check("android", function (package)
            if package:is_plat("android") and package:is_arch("armeabi-v7a") then
                local ndk_sdkver = package:toolchain("ndk"):config("ndk_sdkver")
                if ndk_sdkver and tonumber(ndk_sdkver) < 24 then
                    raise("package(benchmark) require ndk api >= 24")
                end
            end    
        end)
    end

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "BENCHMARK_STATIC_DEFINE")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DBENCHMARK_ENABLE_TESTING=OFF",
            "-DBENCHMARK_INSTALL_DOCS=OFF",
            "-DBENCHMARK_ENABLE_WERROR=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBENCHMARK_ENABLE_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DBENCHMARK_ENABLE_EXCEPTIONS=" .. (package:config("exceptions") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void BM_empty(benchmark::State& state) {
              for (auto _ : state) {}
            }
            BENCHMARK(BM_empty);
            BENCHMARK(BM_empty)->ThreadPerCpu();
        ]]}, {configs = {languages = "c++14"}, includes = "benchmark/benchmark.h"}))
    end)
