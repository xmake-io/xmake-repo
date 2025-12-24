package("libdeflate")
    set_homepage("https://github.com/ebiggers/libdeflate")
    set_description("libdeflate is a library for fast, whole-buffer DEFLATE-based compression and decompression.")
    set_license("MIT")

    add_urls("https://github.com/ebiggers/libdeflate/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ebiggers/libdeflate.git")

    add_versions("v1.25", "d11473c1ad4c57d874695e8026865e38b47116bbcb872bfc622ec8f37a86017d")
    add_versions("v1.24", "ad8d3723d0065c4723ab738be9723f2ff1cb0f1571e8bfcf0301ff9661f475e8")
    add_versions("v1.23", "1ab18349b9fb0ce8a0ca4116bded725be7dcbfa709e19f6f983d99df1fb8b25f")
    add_versions("v1.22", "7f343c7bf2ba46e774d8a632bf073235e1fd27723ef0a12a90f8947b7fe851d6")
    add_versions("v1.21", "50827d312c0413fbd41b0628590cd54d9ad7ebf88360cba7c0e70027942dbd01")
    add_versions("v1.20", "ed1454166ced78913ff3809870a4005b7170a6fd30767dc478a09b96847b9c2a")
    add_versions("v1.8", "50711ad4e9d3862f8dfb11b97eb53631a86ee3ce49c0e68ec2b6d059a9662f61")
    add_versions("v1.10", "5c1f75c285cd87202226f4de49985dcb75732f527eefba2b3ddd70a8865f2533")
    add_versions("v1.13", "0d81f197dc31dc4ef7b6198fde570f4e8653c77f4698fcb2163d820a9607c838")
    add_versions("v1.15", "58b95040df7383dc0413defb700d9893c194732474283cc4c8f144b00a68154b")
    add_versions("v1.17", "fa4615af671513fa2a53dc2e7a89ff502792e2bdfc046869ef35160fcc373763")
    add_versions("v1.19", "27bf62d71cd64728ff43a9feb92f2ac2f2bf748986d856133cc1e51992428c25")

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
            if vs_toolset and package:is_arch("arm.*") then
                local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                local minor = vs_toolset_ver:minor()
                assert(minor and minor >= 30, "package(libdeflate/arm): requires vs_toolset >= 14.3")
            end
        end)
    end

    on_load("windows", function (package)
        if package:config("shared") then
            package:add("defines", "LIBDEFLATE_DLL")
        end
    end)

    on_install(function (package)
        local configs = {"-DLIBDEFLATE_BUILD_GZIP=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBDEFLATE_BUILD_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DLIBDEFLATE_BUILD_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libdeflate_alloc_compressor", {includes = "libdeflate.h"}))
    end)
