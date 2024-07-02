package("cosmocc")
    set_kind("toolchain")
    set_homepage("https://github.com/jart/cosmopolitan")
    set_description("build-once run-anywhere c library")

    add_urls("https://cosmo.zip/pub/cosmocc/cosmocc-$(version).zip",
             "https://github.com/xmake-mirror/cosmopolitan/releases/download/$(version)/cosmocc-$(version).zip")

    add_versions("3.2.4", "d2fa6dbf6f987310494581deff5b915dbdc5ca701f20f7613bb0dcf1de2ee511")
    add_versions("3.3.2", "a695012ffbeac5e26e3c4a740debc15273f47e9a8bdc55e8b76a623154d5914b")
    add_versions("3.3.4", "98e5b361c525603f5296351e0c11820fd25908b52fe1ce8ff394d66b1537a259")
    add_versions("3.3.5", "db78fd8d3f8706e9dff4be72bf71d37a3f12062f212f407e1c33bc4af3780dd0")
    add_versions("3.3.6", "26e3449357f31b82489774ef5c2d502a711bb711d4faf99a5fd6c96328a1c205")
    add_versions("3.3.7", "638c2c2d9ba968c240e296b3cf901ac60d3a6d9205eff68356673db47a94d836")
    add_versions("3.3.8", "61208872dea249fb9621e950a15f438d2db70b0ca3aa3e91f5e8d0b078fc328d")
    add_versions("3.3.9", "0a8a781710f58373077a91ca16a2fafc30a0bc3982fb9b9c5583f045833eca36")
    add_versions("3.3.10", "00d61c1215667314f66e288c8285bae38cc6137fca083e5bba6c74e3a52439de")
    add_versions("3.4.0", "475e24b84a18973312433f5280e267acbe1b4dac1b2e2ebb3cfce46051a8c08c")
    add_versions("3.5.0", "6c8443078ce43bf15bb835c8317d6d44e694e1572023263359c082afb7ec2224")
    add_versions("3.5.1", "ea1f47cd4ead6ce3038551be164ad357bd45a4b5b7824871c561d2af23f871d6")

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
