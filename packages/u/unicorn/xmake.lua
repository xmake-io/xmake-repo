package("unicorn")
    set_homepage("http://www.unicorn-engine.org")
    set_description("Unicorn CPU emulator framework (ARM, AArch64, M68K, Mips, Sparc, PowerPC, RiscV, S390x, X86)")

    add_urls("https://github.com/unicorn-engine/unicorn.git")
    add_versions("2022.02.13", "c10639fd4658a852049546162d116b123e2b1ec2")

    add_deps("cmake")
    add_deps("glib")

    add_links("unicorn", "unicorn-common", "aarch64-softmmu", "sparc-softmmu", "riscv64-softmmu", "arm-softmmu", "m68k-softmmu", "x86_64-softmmu", "s390x-softmmu", "mips64-softmmu", "sparc64-softmmu", "ppc-softmmu", "ppc64-softmmu", "mipsel-softmmu", "riscv32-softmmu", "mips-softmmu", "mips64el-softmmu")

    on_install("windows", "macosx", "linux", function (package)
        local configs = {
            "-DUNICORN_BUILD_TESTS=OFF",
            "-DUNICORN_STATIC_MSVCRT=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        os.trycp("build/*.a", package:installdir("lib"))
        os.trycp("build/*.lib", package:installdir("lib"))
        os.trycp("build/*.dylib", package:installdir("lib"))
        os.trycp("build/*.so", package:installdir("lib"))
        os.trycp("build/*.dll", package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uc_open", {includes = "unicorn/unicorn.h"}))
    end)
