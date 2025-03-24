package("linux-syscall-support")
    set_homepage("https://chromium.googlesource.com/linux-syscall-support")
    set_description("Linux Syscall Support provides a header file that can be included into your application whenever you need to make direct system calls.")
    set_license("BSD-3-Clause")

    add_urls("https://chromium.googlesource.com/linux-syscall-support/+archive/refs/tags/$(version).tar.gz",
             "https://chromium.googlesource.com/linux-syscall-support.git")

    add_versions("v2022.10.12", "44fa671ed2025304a6eb7edfdf220e722666776ed425e7e17247521eb775201a")
    add_versions("v2024.02.01", "7067663bd165fc3a914a94385137bc8c8a70d4d613338a8bdf753787a1d22d86")

    set_kind("library", {headeronly = true})

    on_install(function (package)
        os.cp("linux_syscall_support.h", package:installdir("include/lss"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sys_open", {includes = "lss/linux_syscall_support.h"}))
    end)
