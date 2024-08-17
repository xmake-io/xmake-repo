package("wigxjpf")
    set_homepage("https://fy.chalmers.se/subatom/wigxjpf/")
    set_description("WIGXJPF evaluates Wigner 3j, 6j and 9j symbols accurately using prime factorisation and multi-word integer arithmetic.")
    set_license("GPL-3.0", "LGPL-3.0")

    set_urls("https://fy.chalmers.se/subatom/wigxjpf/wigxjpf-$(version).tar.gz")
    add_versions("1.13", "90ab9bfd495978ad1fdcbb436e274d6f4586184ae290b99920e5c978d64b3e6a")

    on_install("linux", "macosx", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "shared")
        end
        import("package.tools.make").build(package, configs)
        os.cp("inc/*.h", package:installdir("include"))
        if package:config("shared") then
            os.cp("lib/*.so", package:installdir("lib"))
        else
            os.cp("lib/*.a", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("wig3jj", {includes = "wigxjpf.h"}))
    end)
