package("b2")

    set_kind("binary")
    set_homepage("https://www.bfgroup.xyz/b2/")
    set_description("B2 makes it easy to build C++ projects, everywhere.")
    set_license("BSL-1.0")

    add_urls("https://github.com/bfgroup/b2/releases/download/$(version)/b2-$(version).zip")
    add_versions("4.9.6", "a049f7fdfae4b62353a3f76f34a72c8c87324d1c026cf87febe6c563311bf687")

    on_install("@windows", function (package)
        os.vrun("bootstrap.bat")
        os.vrunv("b2.exe", {"install", "--prefix=" .. package:installdir()})
        package:addenv("PATH", ".")
    end)

    on_install("@macosx", "@linux", "@bsd", "@msys", "@cygwin", function (package)
        os.vrun("sh ./bootstrap.sh")
        local configs = {"install", "--prefix=" .. package:installdir()}
        if package:has_tool("cc", "gcc", "gxx") then
            table.insert(configs, "toolset=gcc")
        elseif package:has_tool("cc", "clang", "clangxx") then
            table.insert(configs, "toolset=clang")
        end
        os.vrunv("./b2", configs)
        package:addenv("PATH", ".")
    end)

    on_test(function (package)
        os.vrun("b2 --help")
    end)
