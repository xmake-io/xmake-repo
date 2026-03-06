package("jnif")
    set_homepage("https://github.com/rdbo/jnif")
    set_description("The Java Native Instrumentation Framework, JNIF, is the first native Java bytecode rewriting library. JNIF is a C++ library for decoding, analyzing, editing, and encoding Java bytecode.")
    set_license("MIT")

    add_urls("https://github.com/rdbo/jnif.git")
    add_versions("2026.03.04", "b6e8473735df7e4b55bd5b3e2a162a7252d7a900")

    add_deps("cmake")
    add_deps("openjdk")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if on_check then
        on_check(function (package)
            if not package:is_arch64() then
                raise("package(jnif) unsupported 32-bit arch")
            end
        end)
    end

    on_install("windows|!x86", "msys|x86_64", "linux", "macosx", function (package)
        io.replace("CMakeLists.txt",
            [[add_library(jnif ${JNIF_SRC})]], [[
            add_library(jnif ${JNIF_SRC})
            include(GNUInstallDirs)
            install(TARGETS jnif
                RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
                LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
                ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            )
        ]], {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        os.cp("src-libjnif/jnif.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                jnif::ClassFile cf("MyClass", "java/lang/Object");
                jnif::u2 idx = cf.addUtf8("HelloFromJNIF");
                jnif::u2 strIdx = cf.addString(idx);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "jnif.hpp"}))
    end)
