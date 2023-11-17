package("which")

    set_kind("binary")
    set_homepage("https://www.gnu.org/software/which/")
    set_description("shows the full path of (shell) commands")

    add_urls("https://ftp.gnu.org/gnu/which/which-$(version).tar.gz",
             "https://carlowood.github.io/which/which-$(version).tar.gz",
             "https://mirrors.ustc.edu.cn/gnu/which/which-$(version).tar.gz")
    add_versions("2.16", "0ac8502e9985a3ac6b0e2aa4f2a60f91cad0dc0cca6dc9c1c142ebba4b8dd664")
    add_versions("2.17", "176fe9c451487eda787dd58d9469d48c95509f49dbb34a574004a936905dd6da")
    add_versions("2.19", "7d79b874f65118ac846a0deb31a8fbd6816cd81e74930299c82103765d45cd52")
    add_versions("2.20", "d417b65c650d88ad26a208293c1c6e3eb60d4b6d847f01ff8f66aca63e2857f8")
    add_versions("2.21", "f4a245b94124b377d8b49646bf421f9155d36aa7614b6ebf83705d3ffc76eaad")

    on_install("@bsd", "@linux", "@macosx", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        os.vrun("which -v")
    end)
