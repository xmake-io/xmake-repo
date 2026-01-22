package("steam-audio")
    set_homepage("https://valvesoftware.github.io/steam-audio/")
    set_description("Valve's steam audio library")
    set_license("Apache-2.0")

    add_urls("https://github.com/ValveSoftware/steam-audio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ValveSoftware/steam-audio.git")

    add_versions("v4.8.0", "8be6a14747b731c6ec63e6917dabff0481d7266cc28743cbec661e49fead58d3")
    add_versions("v4.7.0", "f194f9c34d18a2a1b5f563bb39888e0eabdef1cd26ddfa959de3f95da4d263ea")
    add_versions("v4.6.1", "9965993d9df46d0585bd1dcb0acd3c5ae031656c75c87bbd49429db37757b65d")
    add_versions("v4.6.0", "b81479bf8fc55c3bbd49c1f9eb1356d7ff7a3a5efc553ba6653ed41715aaf368")

    add_configs("fft", {description = "Choice fft library", default = "pffft", type = "string", values = {"ipp", "ffts", "pffft"}})
    add_configs("mkl", {description = "Enable Intel MKL support for linear algebra operations.", default = false, type = "boolean"})
    add_configs("embree", {description = "Enable Intel Embree support for ray tracing.", default = false, type = "boolean"})
    add_configs("radeonrays", {description = "Enable AMD Radeon Rays support for GPU-accelerated ray tracing.", default = false, type = "boolean"})
    add_configs("trueaudio_next", {description = "Enable AMD TrueAudio Next support for GPU-accelerated convolution.", default = false, type = "boolean", readonly = true})
    add_configs("abi", {description = "Apply some unsafe patch for linux and macos build, maybe abi break", default = true, type = "boolean"})

    add_deps("cmake")
    add_deps("libmysofa", "flatbuffers")

    if is_plat("windows") then
        add_syslinks("delayimp")
    elseif is_plat("linux") then
        add_syslinks("m", "dl", "pthread")
    elseif is_plat("android") then
        add_syslinks("log", "android")
    end

    on_check(function (package)
        if package:version() and package:version():ge("4.7.0") and package:has_tool("cxx", "clang") then
            raise("package(steam-audio >=4.7.0) unsupported clang")
        end
    end)

    on_load(function (package)
        package:add("deps", package:config("fft"))
        if package:config("mkl") then
            package:add("deps", "mkl")
        end
        if package:config("embree") then
            package:add("deps", "ispc", "embree")
        end
        if package:config("radeonrays") then
            package:add("deps", "python 3.x", {kind = "binary"})
            package:add("deps", "radeonrays")
        end

        if package:is_cross() then
            package:add("deps", "flatbuffers~host", {kind = "binary", private = true})
        end
    end)

    on_install("!bsd and !mingw and !cross", function (package)
        os.cd("core")
        import("patch")(package)

        local configs = {
            "-DSTEAMAUDIO_BUILD_TESTS=OFF",
            "-DSTEAMAUDIO_BUILD_BENCHMARKS=OFF",
            "-DSTEAMAUDIO_BUILD_SAMPLES=OFF",
            "-DSTEAMAUDIO_BUILD_ITESTS=OFF",
            "-DSTEAMAUDIO_BUILD_DOCS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        local fft = package:config("fft")
        table.insert(configs, "-DSTEAMAUDIO_ENABLE_IPP=" .. (fft == "ipp" and "ON" or "OFF"))
        table.insert(configs, "-DSTEAMAUDIO_ENABLE_FFTS=" .. (fft == "ffts" and "ON" or "OFF"))
        table.insert(configs, "-DSTEAMAUDIO_ENABLE_MKL=" .. (package:config("mkl") and "ON" or "OFF"))
        table.insert(configs, "-DSTEAMAUDIO_ENABLE_EMBREE=" .. (package:config("embree") and "ON" or "OFF"))
        table.insert(configs, "-DSTEAMAUDIO_ENABLE_RADEONRAYS=" .. (package:config("radeonrays") and "ON" or "OFF"))
        table.insert(configs, "-DSTEAMAUDIO_ENABLE_TRUEAUDIONEXT=" .. (package:config("trueaudio_next") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        os.mv(package:installdir("lib/*.dll"), package:installdir("bin"))
        if package:is_plat("windows") and package:config("shared") then
            local phonon_h = path.join(package:installdir("include"), "phonon.h")
            io.replace(phonon_h, "#define IPLAPI\n#endif", "#define IPLAPI __declspec(dllimport)\n#endif", {plain = true})
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                IPLContextSettings contextSettings{};
                contextSettings.version = STEAMAUDIO_VERSION;
                IPLContext context = nullptr;
                iplContextCreate(&contextSettings, &context);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "phonon.h"}))
    end)
