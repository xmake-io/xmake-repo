package("cosmocc")
    set_kind("toolchain")
    set_homepage("https://github.com/jart/cosmopolitan")
    set_description("build-once run-anywhere c library")

    add_urls("https://cosmo.zip/pub/cosmocc/cosmocc-$(version).zip",
             "https://github.com/xmake-mirror/cosmopolitan/releases/download/$(version)/cosmocc-$(version).zip")
    add_versions("3.2.4", "d2fa6dbf6f987310494581deff5b915dbdc5ca701f20f7613bb0dcf1de2ee511")

    on_load("@windows|x64", function (package)
        package:add("deps", "msys2")
    end)

    on_install("@windows", "@macosx", "@linux", "@bsd", "@cygwin", "@msys", function (package)
        if is_host("windows") then
            import("lib.detect.find_tool")
            assert(find_tool("sh"), "cosmocc need sh/bash, please install it first!")
        end
        os.cp("*", package:installdir(), {symlink = true})
    end)

    on_test(function (package)
        local cosmocc = path.join(package:installdir("bin"), "cosmocc")
        os.vrunv(cosmocc, {"--version"}, {shell = true})
    end)
