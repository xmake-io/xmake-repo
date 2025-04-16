package("csfml")
    set_homepage("https://www.sfml-dev.org/")
    set_description("CSFML is the official binding of SFML for the C language.")
    set_license("zlib")

    add_urls("https://github.com/SFML/CSFML/archive/refs/tags/$(version).tar.gz", "https://github.com/SFML/CSFML.git")

    add_versions("2.6.1", "f3f3980f6b5cad85b40e3130c10a2ffaaa9e36de5f756afd4aacaed98a7a9b7b")

    add_deps("sfml =2.6.1")

    on_load(function (package)
        package:config_set("shared", true)
        if package:dep("sfml") then
             package:dep("sfml"):config_set("shared", package:config("shared"))
        end
    end)

    on_install(function (package)
        local configs = {}
        configs.CMAKE_INSTALL_PREFIX = package:installdir()
        configs.BUILD_SHARED_LIBS = package:config("shared") and "ON" or "OFF"

        local sfml_pkg = package:dep("sfml")
        if sfml_pkg then
            local sfml_installdir = sfml_pkg:installdir()
            if sfml_installdir and os.isdir(sfml_installdir) then
                 local sfml_cmakedir = path.join(sfml_installdir, "lib", "cmake", "SFML")
                 local sfml_cmakedir_alt = path.join(sfml_installdir, "lib", "cmake", "sfml")

                 if os.isdir(sfml_cmakedir) then
                     configs.SFML_DIR = sfml_cmakedir
                 elseif os.isdir(sfml_cmakedir_alt) then
                     configs.SFML_DIR = sfml_cmakedir_alt
                 end
            else
                 error("SFML dependency package data not found for CSFML build.")
            end
        else
            error("SFML dependency package object not found.")
        end

        if not package:config("shared") and package:is_plat("linux", "bsd", "macosx") then
            configs.CMAKE_POSITION_INDEPENDENT_CODE = "ON"
        end

        import("package.tools.cmake")
        cmake.install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cincludes("SFML/Window.h"))
    end)
