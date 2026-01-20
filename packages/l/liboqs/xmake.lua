package("liboqs")
    set_homepage("https://openquantumsafe.org")
    set_description("C library for prototyping and experimenting with quantum-resistant cryptography")
    set_license("MIT")

    add_urls("https://github.com/open-quantum-safe/liboqs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/open-quantum-safe/liboqs.git")

    add_versions("0.15.0", "3983f7cd1247f37fb76a040e6fd684894d44a84cecdcfbdb90559b3216684b5c")
    add_versions("0.14.0", "5b0df6138763b3fc4e385d58dbb2ee7c7c508a64a413d76a917529e3a9a207ea")
    add_versions("0.13.0", "789e9b56bcb6b582467ccaf5cdb5ab85236b0c1007d30c606798fa8905152887")
    add_versions("0.12.0", "df999915204eb1eba311d89e83d1edd3a514d5a07374745d6a9e5b2dd0d59c08")
    add_versions("0.11.0", "f77b3eff7dcd77c84a7cd4663ef9636c5c870f30fd0a5b432ad72f7b9516b199")
    add_versions("0.10.1", "00ca8aba65cd8c8eac00ddf978f4cac9dd23bb039f357448b60b7e3eed8f02da")

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32")
    end

    add_deps("cmake")

    if on_check then
        on_check("windows", function (package)
            local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
            if vs_toolset then
                local vs_toolset_ver = import("core.base.semver").new(vs_toolset)
                local minor = vs_toolset_ver:minor()
                assert(minor and minor >= 30, "package(liboqs) require vs_toolset >= 14.3")
            end
        end)
    end

    on_install("!windows or windows|!arm64", function (package)
        io.replace(".CMake/compiler_opts.cmake", "add_compile_options(/MT)", "", {plain = true})

        local configs = {"-DOQS_BUILD_ONLY_LIB=ON", "-DOQS_USE_OPENSSL=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("cross", "iphoneos") or (package:is_plat("mingw") and package:is_arch("i386")) then
            table.insert(configs, "-DOQS_PERMIT_UNSUPPORTED_ARCHITECTURE=ON")
        end

        if package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_COMPILE_PDB_OUTPUT_DIRECTORY=.")
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:config("shared") and "bin" or "lib"
            os.vcp(path.join(package:buildir(), dir, "*.pdb"), package:installdir(dir))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("OQS_SIG_keypair", {includes = "oqs/oqs.h"}))
    end)
