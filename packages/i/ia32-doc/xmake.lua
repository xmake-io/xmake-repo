package("ia32-doc")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ia32-doc/ia32-doc")
    set_description("C/C++ headers for Intel Architecture Software Developer's Manual")
    set_license("MIT")
    add_urls("https://github.com/ia32-doc/ia32-doc.git")
    add_versions("2025.01.31", "2bc5284e04ff862220def160517bc72baf3d1a03")

    add_configs("header_type", {
        description = "The header file type to use",
        default = "hpp",
        values = {"h", "hpp", "compact", "defines_only"}
    })

    on_install(function (package)
        local header_map = {
            h            = "ia32.h",
            hpp          = "ia32.hpp",
            compact      = "ia32_compact.h",
            defines_only = "ia32_defines_only.h"
        }

        local selected_file = header_map[package:config("header_type")]
        local src_file = "out/" .. selected_file
        os.cp(src_file, package:installdir("include") .. "/ia32.h")
    end)
    
    on_test(function (package)
        assert(package:has_cxxincludes("ia32.h"))
    end)
