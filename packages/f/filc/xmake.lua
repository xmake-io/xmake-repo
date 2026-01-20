package("filc")
    set_kind("toolchain")
    set_homepage("https://fil-c.org/")
    set_description("A memory safe implementation of the C and C++ programming languages.")
    set_license("LLVM")

    if is_host("linux") then
        if os.arch() == "x86_64" then
            set_urls("https://github.com/pizlonator/fil-c/releases/download/v$(version)/filc-$(version)-linux-x86_64.tar.xz")
            add_versions("0.674", "a8ec349f383a49dacc09a9540643164c67081245e591c1e6823609653f2c9740")
        end
    end

    add_deps("patchelf") -- needed for setup.sh

    on_install("@linux|x86_64", function (package)
        local installdir = package:installdir()
        os.cp(path.join(os.curdir(), "*"), installdir)

        -- now we replicate the commands in setup.sh...
        local pathx = path.join(installdir, "pizfix/lib64") .. ":" .. path.join(installdir, "pizfix/lib")
        os.runv("patchelf", {"--set-rpath", pathx, "pizfix/lib/libc.so"})
        os.runv("patchelf", {"--set-rpath", pathx, "pizfix/lib/libpizlo.so"})
        os.runv("patchelf", {"--set-rpath", pathx, "pizfix/lib/libc++.so.1.0"})
        os.runv("patchelf", {"--set-rpath", pathx, "pizfix/lib/libc++abi.so.1.0"})
        os.runv("patchelf", {"--set-rpath", pathx, "pizfix/lib_test/libpizlo.so"})
        os.runv("patchelf", {"--set-rpath", pathx, "pizfix/lib_test_gcverify/libpizlo.so"})
        os.runv("patchelf", {"--set-rpath", pathx, "pizfix/lib_gcverify/libpizlo.so"})

        local dest = path.join(installdir, "pizfix", "os-include")
        os.ln("/usr/include/linux", path.join(dest, "linux"))
        if os.exists("/usr/include/x86_64-linux-gnu/asm") then
            os.ln("/usr/include/x86_64-linux-gnu/asm", path.join(dest, "asm"))
        else
            os.ln("/usr/include/asm", path.join(dest, "asm"))
        end
        os.ln("/usr/include/asm-generic", path.join(dest, "asm-generic"))

        -- we must preserve relative directory positions
        package:addenv("PATH", "build/bin")
    end)

    on_test(function (package)
        os.vrun("filcc --version")
    end)

