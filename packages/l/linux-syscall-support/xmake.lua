package("linux-syscall-support")
    set_homepage("https://chromium.googlesource.com/linux-syscall-support")
    set_description("Linux Syscall Support provides a header file that can be included into your application whenever you need to make direct system calls.")
    set_license("BSD-3-Clause")

    add_urls("https://chromium.googlesource.com/linux-syscall-support.git")
    add_versions("v2022.10.12", "9719c1e1e676814c456b55f5f070eabad6709d31")

    on_install("linux", function (package)
        os.cp("linux_syscall_support.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sys_open", {includes = "linux_syscall_support.h"}))
    end)
