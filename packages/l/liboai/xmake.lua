package("liboai")
    set_homepage("https://github.com/D7EAD/liboai")
    set_description("A C++17 library to access the entire OpenAI API.")
    set_license("MIT")

    set_urls("https://github.com/D7EAD/liboai/archive/refs/tags/$(version).tar.gz",
             "https://github.com/D7EAD/liboai.git")

    add_versions("v4.0.1", "abe127ae1cd3049f19976e31d8414e8130a73d7978552e863b767fe04b20697f")
    add_versions("v3.2.1", "9058bcc1485967061c9c33b2e7a109a254cdf71638b1448f21cfefd7ffd9c4fa")

    add_deps("nlohmann_json")
    add_deps("libcurl", {configs = {openssl = true, zlib = true}})

    on_install("windows", "linux", "macosx", function (package)
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
        import("package.tools.xmake").install(package)
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
