package("udt")
    set_homepage("https://github.com/dorkbox/UDT")
    set_description("UDP-based Data Transfer Protocol")
    set_license("Apache-2.0")

    add_urls("https://github.com/dorkbox/UDT/archive/8272c251deb8bfd7289646b7604f1079b59194d0.tar.gz",
             "https://github.com/dorkbox/UDT.git")

    add_versions("2017.12.03", "af743ffdb2e40225d7375df1a3d6320127b903322af4021460681f1052b7461e")

    if is_plat("windows", "mingw") then
        add_defines("WINDOWS")
        add_syslinks("Ws2_32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    on_install("!windows or windows|!x86", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("udt")
                set_kind("$(kind)")
                if is_mode("debug") then
                    add_defines("_DEBUG")
                end
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
                set_languages("cxx11")
                if is_plat("windows", "mingw") then
                    add_defines("WINDOWS")
                    add_syslinks("Ws2_32")
                elseif is_plat("linux", "bsd") then
                    add_syslinks("pthread", "m")
                end
                add_files("src/*.cpp")
                add_headerfiles("src/udt.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                UDT::startup();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "udt.h"}))
    end)
