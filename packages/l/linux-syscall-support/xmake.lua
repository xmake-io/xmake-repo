package("linux-syscall-support")
    set_homepage("https://chromium.googlesource.com/linux-syscall-support")
    set_description("Linux Syscall Support provides a header file that can be included into your application whenever you need to make direct system calls.")
    set_license("BSD-3-Clause")

    add_urls("https://chromium.googlesource.com/linux-syscall-support.git")
    add_versions("v2022.10.12", "9719c1e1e676814c456b55f5f070eabad6709d31")
    add_versions("v2024.02.01", "ed31caa60f20a4f6569883b2d752ef7522de51e0")

    set_kind("library", {headeronly = true})

    on_install("android", "linux", "cross",  function (package)
        os.cp("linux_syscall_support.h", package:installdir("include/lss"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sys_open", {includes = "lss/linux_syscall_support.h"}))
    end)
