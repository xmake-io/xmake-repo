package("git-crypt")
    set_kind("binary")
    set_homepage("https://www.agwa.name/projects/git-crypt/")
    set_description("Transparent file encryption in git")
    set_license("GPL-3.0")

    add_urls("https://github.com/AGWA/git-crypt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AGWA/git-crypt.git")
    add_versions("0.7.0", "2210a89588169ae9a54988c7fdd9717333f0c6053ff704d335631a387bd3bcff")

    add_deps("openssl")
    
    on_install("linux", "macosx", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("openssl")
            target("git-crypt")
                set_kind("binary")
                add_packages("openssl")
                add_files("*.cpp")
                add_headerfiles("*.hpp")
                remove_files("*-unix.cpp", "*-win32.cpp")
                remove_headerfiles("*-unix.hpp", "*-win32.hpp")

        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("git-crypt --version")
    end)
