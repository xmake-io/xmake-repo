package("bison")
    set_kind("binary")
    set_homepage("https://www.gnu.org/software/bison/")
    set_description("A general-purpose parser generator.")
    set_license("GPL-3.0")

    if not is_plat("windows") then
        add_urls("http://ftp.gnu.org/gnu/bison/bison-$(version).tar.gz")
    end

    add_versions("3.7.4", "fbabc7359ccd8b4b36d47bfe37ebbce44805c052526d5558b95eda125d1677e2")
    add_versions("3.7.6", "69dc0bb46ea8fc307d4ca1e0b61c8c355eb207d0b0c69f4f8462328e74d7b9ea")
    add_versions("3.8.2", "06c9e13bdf7eb24d4ceb6b59205a4f67c2c7e7213119644430fe82fbd14a0abb")

    if is_plat("windows") then
        add_deps("winflexbison", {private = true})
    elseif is_plat("linux", "bsd") then
        add_deps("m4")
    end

    on_load("macosx", "linux", "bsd", "windows", function (package)
        -- we always set it, because flex may be modified as library
        -- by add_deps("bison", {kind = "library"})
        package:addenv("PATH", "bin")
    end)

    on_install(function (package)
        if package:is_plat("windows") then
            os.cp(path.join(package:dep("winflexbison"):installdir(), "*"), package:installdir())
            os.rm(path.join(package:installdir(), "bin", "flex.exe"))
            os.rm(path.join(package:installdir(), "include", "FlexLexer.h"))
        else
            import("package.tools.autoconf").install(package)
            os.rm(package:installdir("share", "doc"))
        end
    end)

    on_test(function (package)
        os.vrun("bison -h")
    end)
