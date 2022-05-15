package("unicorn")
    set_homepage("http://www.unicorn-engine.org")
    set_description("Unicorn CPU emulator framework (ARM, AArch64, M68K, Mips, Sparc, PowerPC, RiscV, S390x, X86)")

    add_urls("https://github.com/unicorn-engine/unicorn.git")
    add_versions("2022.02.13", "c10639fd4658a852049546162d116b123e2b1ec2")

    add_deps("cmake")
    add_deps("glib")

    local archs = {"aarch64", "sparc", "sparc", "riscv64", "arm", "m68k",
                   "x86_64", "s390x", "mips64", "sparc64", "ppc", "ppc64",
                   "mipsel", "riscv32", "mips", "mips64el"}
    add_configs("arch", {description = "Select unicorn architecture for softmmu.", default = "aarch64", values = archs})

    on_load(function (package)
        package:add("links", "unicorn")
        package:add("links", package:config("arch") .. "-softmmu")
        package:add("links", "unicorn-common")
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {
            "-DUNICORN_BUILD_TESTS=OFF",
            "-DUNICORN_STATIC_MSVCRT=OFF"}
        local arch = package:config("arch")
        if arch == "x86_64" then
            table.insert(configs, "-DUNICORN_ARCH=x86")
        elseif arch:startswith("riscv") then
            table.insert(configs, "-DUNICORN_ARCH=riscv")
        elseif arch:startswith("mips") then
            table.insert(configs, "-DUNICORN_ARCH=mips")
        elseif arch:startswith("ppc") then
            table.insert(configs, "-DUNICORN_ARCH=ppc")
        else
            table.insert(configs, "-DUNICORN_ARCH=" .. arch)
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        if package:is_plat("windows") then
            os.cp("include", package:installdir())
        end
        os.trycp("build/*.a", package:installdir("lib"))
        os.trycp("build/*.lib", package:installdir("lib"))
        os.trycp("build/*.dylib", package:installdir("lib"))
        os.trycp("build/*.so", package:installdir("lib"))
        os.trycp("build/*.dll", package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("uc_open", {includes = "unicorn/unicorn.h"}))
    end)
