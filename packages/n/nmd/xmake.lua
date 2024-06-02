package("nmd")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Nomade040/nmd")
    set_description("An x86 assembler and disassembler along with a C89 header file (nmd_assembly.h), and a C89 2D graphics library (nmd_graphics.h).")
    set_license("Unlicense")

    add_urls("https://github.com/Nomade040/nmd.git")
    add_versions("2021.03.28", "33ac3b62c7d1eb28ae6b71d4dd78aa133ef96488")

    add_includedirs("include", "include/nmd")

    on_install(function (package)
        os.cp("nmd_assembly.h", package:installdir("include/nmd"))
        os.cp("nmd_graphics.h", package:installdir("include/nmd"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <nmd/nmd_assembly.h>
            void test() {
                nmd_x86_instruction instruction;
            }
        ]]}, {configs = {languages = "c89"}}))
    end)
