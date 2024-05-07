package("wigxjpf")
    set_homepage("https://fy.chalmers.se/subatom/wigxjpf/")
    set_description("WIGXJPF evaluates Wigner 3j, 6j and 9j symbols accurately using prime factorisation and multi-word integer arithmetic.")
    set_license("GPL-3.0", "LGPL-3.0")

    set_urls("https://fy.chalmers.se/subatom/wigxjpf/wigxjpf-$(version).tar.gz")
    add_versions("1.13", "90ab9bfd495978ad1fdcbb436e274d6f4586184ae290b99920e5c978d64b3e6a")

    on_install("linux", "macosx", function (package)
        os.vrun("make")
        os.cp("inc/*.h", package:installdir("include"))
        os.cp("lib/*.a", package:installdir("lib"))
        os.cp("bin/*", package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include "wigxjpf.h"
            int test()
            {
                double val6j;
                wig_table_init(2*100, 9);
                wig_temp_init(2*100);
                val6j = wig6jj(2*  2 , 2*  2 , 2*  1 ,
                                2*  2 , 2*  1 , 2*  1 );
                wig_temp_free();
                wig_table_free();
                return 0;
            }
        ]]}))
    end)
