package("b2")

    set_kind("binary")
    set_homepage("https://www.bfgroup.xyz/b2/")
    set_description("B2 makes it easy to build C++ projects, everywhere.")
    set_license("BSL-1.0")

    add_urls("https://github.com/bfgroup/b2/releases/download/$(version)/b2-$(version).zip")
    add_versions("5.4.2", "57bc04dcee007d06ccf228fa300205f99482a687c578e79882be83836d06e1eb")
    add_versions("5.3.3", "1c8be6d0ce5c395a59871b7c1b8d4f1ac21dadc72c654eacb2f57245983cff26")
    add_versions("5.3.2", "f12781fc9d20f323ec2c9c730847076b30c980a67375c88f9464c2f118bc976b")
    add_versions("5.3.0", "cf2b83411d28d04546a4274f4b421a73e6b1700eba6f8211192ee1670e31cccd")
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
