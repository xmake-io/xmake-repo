package("coin-or-asl")
    set_homepage("https://github.com/coin-or-tools/ThirdParty-ASL/")
    set_description("The Advanced Linux Sound Architecture (ALSA) provides audio and MIDI functionality to the Linux operating system.")
    set_license("EPL-1.0")

    add_urls("https://github.com/coin-or-tools/ThirdParty-ASL/archive/refs/tags/releases/$(version).tar.gz",
             "https://github.com/coin-or-tools/ThirdParty-ASL.git")

    add_versions("2.0.1", "92575a7d5264311a53bfec65bec006475c4b5ef3e79d8d84db798d73e8d3567f")

    if is_plat("linux") then
        add_deps("autoconf", "automake", "libtool", "m4")
        add_syslinks("dl")
    end

    add_includedirs("include", "include/coin-or")

    on_install("linux", function (package)
        os.vrunv("sh", {"./get.ASL"})
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ASL_alloc", {includes = "asl/asl.h"}))
    end)
