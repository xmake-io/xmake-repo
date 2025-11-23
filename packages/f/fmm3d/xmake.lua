package("fmm3d")
    set_homepage("https://fmm3d.readthedocs.io/")
    set_description("A set of libraries to compute N-body interactions governed by the Laplace and Helmholtz equations, to a specified precision, in three dimensions, on a multi-core shared-memory machine.")
    set_license("Apache-2.0")

    set_urls("https://github.com/flatironinstitute/FMM3D/archive/refs/tags/$(version).zip",
             "https://github.com/flatironinstitute/FMM3D.git")
    add_versions("v1.0.4", "59fa04965cd46cd564ba4784d91f00f8b0d24e0a08967a7b90f076dd5eb30faf")

    if is_plat("windows") then
        add_deps("mingw-w64", "make")
    end

    on_install("linux", "macosx", "windows", function (package)
        if package:is_plat("windows") then
            os.cp("make.inc.windows.mingw", "make.inc")

            io.replace("makefile", "mkdir -p $(FMM_INSTALL_DIR)", "", {plain = true})
            io.replace("makefile", "cp -f lib/$(DYNAMICLIB) $(FMM_INSTALL_DIR)/", "copy /y lib\\$(DYNAMICLIB) $(FMM_INSTALL_DIR)", {plain = true})
            io.replace("makefile", "cp -f lib-static/$(STATICLIB) $(FMM_INSTALL_DIR)/", "copy /y lib-static\\$(STATICLIB) $(FMM_INSTALL_DIR)", {plain = true})
            io.replace("makefile", "[ ! -f lib/$(LIMPLIB) ] || cp lib/$(LIMPLIB) $(FMM_INSTALL_DIR)/", "if exist lib\\$(LIMPLIB) copy lib\\$(LIMPLIB) $(FMM_INSTALL_DIR)", {plain = true})

            io.replace("makefile", "mv $(STATICLIB) lib-static/", "move $(STATICLIB) lib-static", {plain = true})
            io.replace("makefile", "mv $(DYNAMICLIB) lib/", "move $(DYNAMICLIB) lib", {plain = true})
            io.replace("makefile", "[ ! -f $(LIMPLIB) ] || mv $(LIMPLIB) lib/", "if exist $(LIMPLIB) move $(LIMPLIB) lib", {plain = true})

            io.replace("makefile", "\" $(FMM_INSTALL_DIR) \"", "$(FMM_INSTALL_DIR)", {plain = true})
            io.replace("makefile", "\"$(FMM_INSTALL_DIR) \"", "$(FMM_INSTALL_DIR)", {plain = true})
        elseif package:is_plat("macosx") then
            os.cp("make.inc.macos.gnu", "make.inc")
        end

        import("package.tools.make").build(package, {"install", "PREFIX=" .. package:installdir("lib")})

        local preface = "  #pragma once\n\n  #include <stdint.h>\n"
        local ex_begin = "\n  #ifdef __cplusplus\n  extern \"C\" {\n  #endif\n"
        local ex_end = "\n  #ifdef __cplusplus\n  }\n  #endif\n"

        io.replace("c/lfmm3d_c.h", "#include \"utils.h\"\n", "", {plain = true})
        local lfmm3d_h = io.readfile("c/lfmm3d_c.h")
        lfmm3d_h = preface .. ex_begin .. lfmm3d_h .. ex_end
        io.writefile("c/lfmm3d_c.h", lfmm3d_h)

        io.replace("c/hfmm3d_c.h", "#include \"utils.h\"\n", "", {plain = true})
        local hfmm3d_h = io.readfile("c/hfmm3d_c.h")
        if package:is_plat("windows") then
            hfmm3d_h = preface .. "  #include <complex.h>\n\n  typedef _Dcomplex CPX;\n" .. ex_begin .. hfmm3d_h .. ex_end
        else
            hfmm3d_h = preface .. "  #include <complex.h>\n\n  typedef double complex CPX;\n" .. ex_begin .. hfmm3d_h .. ex_end
        end
        io.writefile("c/hfmm3d_c.h", hfmm3d_h)

        os.cp("c/lfmm3d_c.h", package:installdir("include"))
        os.cp("c/hfmm3d_c.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lfmm3d_s_c_p_", {includes = {"lfmm3d_c.h"}, configs = {languages = "c99"}}))
        assert(package:has_cfuncs("hfmm3d_s_c_p_", {includes = {"hfmm3d_c.h"}, configs = {languages = "c99"}}))
    end)
