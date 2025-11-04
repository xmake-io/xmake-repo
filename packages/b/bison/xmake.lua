package("bison")
    set_kind("binary")
    set_homepage("https://www.gnu.org/software/bison/")
    set_description("A general-purpose parser generator.")
    set_license("GPL-3.0")

    if on_source then
        on_source(function (package)
            if not package:is_plat("windows", "mingw", "msys") then
                package:add("urls", "https://ftp.gnu.org/gnu/bison/bison-$(version).tar.gz",
                                    "https://mirrors.ustc.edu.cn/gnu/bison/bison-$(version).tar.gz",
                                    "https://mirror.csclub.uwaterloo.ca/gnu/bison/bison-$(version).tar.gz")
            end
        end)
    elseif not is_plat("windows", "mingw", "msys") then
        add_urls("https://ftp.gnu.org/gnu/bison/bison-$(version).tar.gz",
                 "https://mirrors.ustc.edu.cn/gnu/bison/bison-$(version).tar.gz",
                 "https://mirror.csclub.uwaterloo.ca/gnu/bison/bison-$(version).tar.gz")
    end

    add_versions("3.7.4", "fbabc7359ccd8b4b36d47bfe37ebbce44805c052526d5558b95eda125d1677e2")
    add_versions("3.7.6", "69dc0bb46ea8fc307d4ca1e0b61c8c355eb207d0b0c69f4f8462328e74d7b9ea")
    add_versions("3.8.2", "06c9e13bdf7eb24d4ceb6b59205a4f67c2c7e7213119644430fe82fbd14a0abb")

    on_load("macosx", "linux", "bsd", "windows", "@msys", function (package)
        if package:is_plat("windows") then
            package:add("deps", "winflexbison", {private = true})
        elseif package:is_plat("linux", "bsd") then
            package:add("deps", "m4")
        end

        -- we always set it, because bison may be modified as library
        -- by add_deps("bison", {kind = "library"})
        package:addenv("PATH", "bin")
        if package:is_library() then
            package:set("kind", "library", {headeronly = true})
        end

        if is_subhost("msys") and xmake:version():ge("2.9.7") then
            package:add("deps", "pacman::bison", {configs = {msystem = "msys"}})
        end
    end)

    on_install("@msys", function (package) end)

    on_install("windows", function (package)
        os.cp(path.join(package:dep("winflexbison"):installdir(), "*"), package:installdir())
        os.rm(path.join(package:installdir(), "bin", "flex.exe"))
        os.rm(path.join(package:installdir(), "include", "FlexLexer.h"))
    end)

    on_install("macosx", "linux", "bsd", "android", "iphoneos", "cross", function (package)
        import("package.tools.autoconf").install(package)
        os.rm(package:installdir("share", "doc"))
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("bison -h")
        end
    end)
