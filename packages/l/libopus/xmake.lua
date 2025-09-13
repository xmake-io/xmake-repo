package("libopus")
    set_homepage("https://opus-codec.org")
    set_description("Modern audio compression for the internet.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/xiph/opus/archive/refs/tags/$(version).tar.gz", {alias = "github"})
    add_urls("https://github.com/xiph/opus.git", {alias = "git"})
    add_urls("https://downloads.xiph.org/releases/opus/opus-$(version).tar.gz", {alias = "home"})

    add_versions("home:1.5.2", "65c1d2f78b9f2fb20082c38cbe47c951ad5839345876e46941612ee87f9a7ce1")
    add_versions("home:1.5.1", "b84610959b8d417b611aa12a22565e0a3732097c6389d19098d844543e340f85")
    add_versions("home:1.5", "d8230bbeb99e6d558645aaad25d79de8f4f28fdcc55f8af230050586d62c4f2c")
    add_versions("home:1.4", "c9b32b4253be5ae63d1ff16eea06b94b5f0f2951b7a02aceef58e3a3ce49c51f")
    add_versions("home:1.3.1", "65b58e1e25b2a114157014736a3d9dfeaad8d41be1c8179866f144a2fb44ff9d")

    add_versions("github:v1.5.2", "9480e329e989f70d69886ded470c7f8cfe6c0667cc4196d4837ac9e668fb7404")
    add_versions("github:v1.5.1", "7ce44ef3d335a3268f26be7d53bb3bed7205b34eaf80bf92a99e69d490afe9d9")
    add_versions("github:v1.5", "d7de528957dde0ba40e9dec9e25b679232bfaf19fb6a02ed8358845007d7075e")
    add_versions("github:v1.4", "659e6b223e42a51b0a898632b9a5f406ccd5c2e00aa526ddd1264789774b94e5")
    add_versions("github:v1.3.1", "4834a8944c33a7ecab5cad9454eeabe4680ca1842cb8f5a2437572dbf636de8f")

    add_versions("git:1.5.2", "v1.5.2")

    add_patches("1.5.2", path.join(os.scriptdir(), "patches", "1.5.2", "add-sse4.1-flag-when-using-clang-cl.patch"), "a5810124b43a3a80dc311192a49027869bcd244859a42f8338d62ae0525ab45b")
    add_patches("1.3.1", path.join(os.scriptdir(), "patches", "1.3.1", "cmake.patch"), "79fba5086d7747d0441f7f156b88e932b662e2d2ccd825279a5a396a2840d3a2")

    add_configs("avx", { description = "AVX supported", default = true, type = "boolean" })
    add_configs("check_avx", { description = "Does runtime check for AVX support", default = true, type = "boolean" })

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::opus")
    elseif is_plat("linux") then
        add_extsources("pacman::opus", "apt::libopus-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::opus")
    end

    add_deps("cmake")

    if on_check then
        on_check(function (package)
            local version = package:version()
            if not version then
                return
            end

            if package:is_plat("linux", "cross") and package:is_arch("arm.*") then
                if version:le("1.4") then
                    raise("package(libopus 1.4) unsupported arch")
                end
            end

            if (package:is_plat("android") and package:is_arch("armeabi-v7a")) or package:is_plat("wasm") then
                if version:eq("1.3.1") then
                    raise("package(libopus 1.3.1) unsupported platform")
                end
            end
        end)
    end

    on_install(function (package)
        io.replace("CMakeLists.txt", [[set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")]], "", {plain = true})
        io.replace("CMakeLists.txt", [[set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")]], "", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if not package:gitref() and package:version() then
            table.insert(configs, "-DOPUS_PACKAGE_VERSION=" .. package:version():shortstr())
        end
        table.insert(configs, "-DAVX_SUPPORTED=" .. (package:config("avx") and "ON" or "OFF"))
        table.insert(configs, "-DOPUS_X86_MAY_HAVE_AVX=" .. (package:config("check_avx") and "ON" or "OFF"))
        if package:is_plat("mingw", "wasm") then
            -- Disable stack protection on MinGW and wasm since it causes link errors
            table.insert(configs, "-DOPUS_STACK_PROTECTOR=OFF")
        elseif package:is_plat("android") then
            table.insert(configs, "-DOPUS_DISABLE_INTRINSICS=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("opus_encoder_create", {includes = "opus/opus.h"}))
    end)
