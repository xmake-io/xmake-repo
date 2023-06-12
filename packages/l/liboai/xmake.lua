package("liboai")

    set_homepage("https://github.com/D7EAD/liboai")
    set_description("A C++17 library to access the entire OpenAI API.")

    set_urls("https://github.com/D7EAD/liboai/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/D7EAD/liboai.git")

    add_versions("3.1.0", "4b3564740f7dbf099c785d5720327a4e7acaca2535d329f487d877ce17524a73")

    add_deps("nlohmann_json")
    add_deps("libcurl", {configs = {openssl = true, zlib = true}})

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("nlohmann_json")
            add_requires("libcurl", {configs = {openssl = true, zlib = true}})
            target("oai")
                set_kind("$(kind)")
                set_languages("c++17")
                add_files("liboai/**.cpp")
                add_includedirs("liboai/include")
                add_headerfiles("liboai/include/(**.h)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
                add_packages("nlohmann_json", "libcurl")
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <liboai.h>
            using namespace liboai;
            void test() {
                OpenAI oai;
                oai.auth.SetKeyEnv("OPENAI_API_KEY");
                Response res = oai.Image->create(
                    "A snake in the grass!",
                    1,
                    "256x256"
                );
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
