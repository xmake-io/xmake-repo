package("mmeter")
    set_homepage("https://github.com/LMauricius/MMeter")
    set_description("A simple WIP profiler library for c++. Include the 2 files and you're ready to go.")
    set_license("MIT")

    set_urls("https://github.com/LMauricius/MMeter/archive/refs/tags/$(version).tar.gz",
             "https://github.com/LMauricius/MMeter.git")

    add_versions("2.0", "7c6186e5e93da09d12c012167bd9247a07345e94e00f57e4f3579188fbd58b5d")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("mmeter")
                set_kind("$(kind)")
                add_files("src/*.cpp")
                add_includedirs("include")
                add_headerfiles("include/*.h")
                set_languages("c++17")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                MMETER_FUNC_PROFILER;
            }
        ]]}, {configs = {languages = "c++17"}, includes = "MMeter.h"}))
    end)
