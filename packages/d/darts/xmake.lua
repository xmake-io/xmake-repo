package("darts")
    set_homepage("http://chasen.org/~taku/software/darts/")
    set_description("C++ Template Library for implementation of Double-Array")
    set_license("BSD")

    -- arch use darts
    -- vcpkg use darts-clone
    add_urls("http://chasen.org/~taku/software/darts/src/darts-$(version).tar.gz")
    add_urls("https://github.com/s-yata/darts-clone.git", {alias = "git", includes = {"src", "include"}})

    add_versions("0.32", "0dfc0b82f0a05d93b92acf849368e54bf93f1de8ffb31ba0a21e45ab9e269285")

    add_versions("git:0.32", "87b71afd6cf784953e3c08f24c64203397f3b724")

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_install(function (package)
        if os.isfile("darts.h") then
            io.replace("darts.h", "register", "", {plain = true})
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("darts")
                set_kind("$(kind)")
                add_files("darts.cpp", "src/darts.cc")
                add_includedirs(".", "include")
                add_headerfiles("darts.h", "include/darts.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <darts.h>
            void test() {
                Darts::DoubleArray da;
            }
        ]]}))
    end)
