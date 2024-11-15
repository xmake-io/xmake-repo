package("jnipp")
    set_homepage("https://github.com/mitchdowd/jnipp")
    set_description("C++ wrapper for the Java Native Interface")
    set_license("MIT")

    add_urls("https://github.com/mitchdowd/jnipp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mitchdowd/jnipp.git")

    add_versions("v1.0.0", "e5ff425e1af81d6c0a80420f5b3a46986cdb5f2a1c34449e2fb262eb2edf885b")

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32")
    end

    add_deps("openjdk", {kind = "library"})

    if on_check then
        on_check(function (package)
            if not package:is_arch64() then
                raise("package(jnipp) unsupported 32-bit arch")
            end
            if package:is_cross() then
                raise("package(jnipp) only support native build")
            end
        end)
    end

    on_install("windows", "linux", "macosx", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("openjdk", {kind = "library"})
            set_languages("c++14")
            target("jnipp")
                set_kind("$(kind)")
                add_files("jnipp.cpp")
                add_headerfiles("jnipp.h")
                add_packages("openjdk")
                if is_plat("windows", "mingw") then
                    add_syslinks("advapi32")
                    if is_kind("shared") then
                        add_rules("utils.symbols.export_all", {export_classes = true})
                    end
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <jnipp.h>
            void test() {
                jni::Vm vm;
                jni::Class Integer = jni::Class("java/lang/Integer");
                jni::Object i = Integer.newInstance("1000");
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
