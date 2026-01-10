package("dexbuilder")
    set_homepage("https://github.com/LSPosed/DexBuilder")
    set_description("Generate dex file by c++")

    add_urls("https://github.com/LSPosed/DexBuilder.git")
    add_versions("2025.12.30", "ac7fb2230954ee311808bad469b0db501f31bfb8")

    add_deps("parallel-hashmap", "zlib")

    if on_check then
        on_check(function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <string_view>
                #include <cstddef>
                void test() {
                    constexpr auto lambda_check = [](std::string_view a) { return a.empty(); };
                    int data[2] = {1, 2};
                    auto [x, y] = data;
                    auto dex_idx = 0zu; 
                }
            ]]}, {configs = {languages = "c++23"}}), "package(dexbuilder) Require at least C++23 (supports '0zu' suffix).")
        end)
    end

    on_install("android", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            set_languages("c++23")

            add_requires("parallel-hashmap", "zlib")
            add_packages("parallel-hashmap", "zlib")

            target("dexbuilder")
                set_kind("$(kind)")
                add_files(  
                    "dex_builder.cc",
                    "dex_helper.cc",
                    "slicer/reader.cc",
                    "slicer/writer.cc",
                    "slicer/dex_ir.cc",
                    "slicer/common.cc",
                    "slicer/dex_format.cc",
                    "slicer/dex_utf8.cc",
                    "slicer/dex_bytecode.cc",
                    "slicer/sha1.cpp")
                add_headerfiles("include/(**.h)",
                                "include/(**.ixx)")
                add_includedirs("include", {public = true})
                add_syslinks("log")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                startop::dex::DexBuilder dex_file;
                startop::dex::ClassBuilder builder{
                    dex_file.MakeClass("xposed.dummy.XRandomSuperClass")};
                builder.setSuperClass(startop::dex::TypeDescriptor::FromClassname("Classname"));
            }
        ]]}, {configs = {languages = "c++23"}, includes = "dex_builder.h"}))
    end)
