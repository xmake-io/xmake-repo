package("valgrind")
    set_kind("binary")
    set_homepage("https://valgrind.org")
    set_description("Valgrind is a GPL'd system for debugging and profiling Linux programs.")
    set_license("GPL-3.0")

    add_urls("https://sourceware.org/pub/valgrind/valgrind-$(version).tar.bz2", {alias = "home"})
    add_urls("https://sourceware.org/git/valgrind.git", {alias = "git"})

    add_versions("home:3.27.0", "5b5937de8257ee8f51698ea71b9711adce98061aa07daa4a685efc3af9215bef")
    add_versions("git:3.27.0", "VALGRIND_3_27_0")

    add_deps("autoconf", "automake")

    add_extsources("apt::valgrind", "pacman::valgrind")

    on_install("linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("valgrind --version")
    end)
