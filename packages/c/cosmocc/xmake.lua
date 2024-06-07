package("cosmocc")
    set_kind("toolchain")
    set_homepage("https://github.com/jart/cosmopolitan")
    set_description("build-once run-anywhere c library")

    add_urls("https://cosmo.zip/pub/cosmocc/cosmocc-$(version).zip",
             "https://github.com/xmake-mirror/cosmopolitan/releases/download/$(version)/cosmocc-$(version).zip")
    add_versions("3.2.4", "d2fa6dbf6f987310494581deff5b915dbdc5ca701f20f7613bb0dcf1de2ee511")
    add_versions("3.3.2", "a695012ffbeac5e26e3c4a740debc15273f47e9a8bdc55e8b76a623154d5914b")
    add_versions("3.3.4", "98e5b361c525603f5296351e0c11820fd25908b52fe1ce8ff394d66b1537a259")

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
