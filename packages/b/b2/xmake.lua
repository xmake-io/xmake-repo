package("b2")

    set_kind("binary")
    set_homepage("https://www.bfgroup.xyz/b2/")
    set_description("B2 makes it easy to build C++ projects, everywhere.")
    set_license("BSL-1.0")

    add_urls("https://github.com/bfgroup/b2/releases/download/$(version)/b2-$(version).zip")
    add_versions("5.2.1", "493102f1dd3f50f2892ce61ee91bd362720ab3fd38fa2ea6912bb2c09da9faa3")
    add_versions("5.1.0", "2bf9618a0baa132d22fdfebf6b40436329172e3ca4b7b8a33e06ed97cd603dad")
    add_versions("5.0.1", "5d3b98c63ed4d0f6114f660bd4eca5df32afa332310878b35c0d0faa04a3b6dd")
    add_versions("5.0.0", "d5f280f466b80b694ccb9696413375522d16e6f811918daeb44a917d5bd6c7b5")
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
