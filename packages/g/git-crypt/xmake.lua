package("git-crypt")
    set_kind("binary")
    set_homepage("https://www.agwa.name/projects/git-crypt/")
    set_description("Transparent file encryption in git")
    set_license("GPL-3.0")

    add_urls("https://github.com/AGWA/git-crypt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AGWA/git-crypt.git")
    add_versions("0.8.0", "786199c24f8b79a54d62b98c24b1113606c4ebd83125e642b228704686305e69")
    add_versions("0.7.0", "2210a89588169ae9a54988c7fdd9717333f0c6053ff704d335631a387bd3bcff")

    if is_plat("linux", "macosx", "mingw@macosx") then
        add_deps("openssl", {host = true})
    end
    
    on_install("linux", "macosx", "mingw@macosx", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("openssl")
            target("git-crypt")
                set_kind("binary")
                add_packages("openssl")
                add_files("*.cpp|*-unix.cpp|*-win32.cpp")
                add_headerfiles("*.hpp|*-unix.hpp|*-win32.hpp")

        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        os.vrun("git-crypt --version")
    end)
