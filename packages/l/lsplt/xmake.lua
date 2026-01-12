package("lsplt")
    set_homepage("https://github.com/LSPosed/LSPlt")
    set_description("Simple PLT hook for Android")

    add_urls("https://github.com/LSPosed/LSPlt.git")
    add_versions("2025.03.26", "7d609ac3c2d8faa0c830b0904024ef5c81a98e6e")

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <vector>
                struct MapInfoStub {
                    unsigned long a;
                    unsigned long b;
                    int c;
                    bool d;
                };
                void test() {
                    std::vector<MapInfoStub> info;
                    info.emplace_back(1UL, 2UL, 3, true); 
                }
            ]]}, {configs = {languages = "c++20"}}), 
            "package(lsplt) requires a compiler supporting C++20.")
        end)
    end

    on_install("android", function (package)
        os.cd("lsplt/src/main/jni")
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            set_languages("c++20")
            target("lsplt")
                set_kind("$(kind)")
                add_files("lsplt.cc", "elf_util.cc")
                add_includedirs(".", "include")
                add_headerfiles("include/(*.hpp)")
                add_syslinks("log")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto b = lsplt::v2::CommitHook();
            }
        ]]}, {configs = {languages = "c++20"}, includes = "lsplt.hpp"}))
    end)
