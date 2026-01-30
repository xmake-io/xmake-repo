package("avisynthplus")
    set_homepage("http://avs-plus.net")
    set_description("AviSynth with improvements")
    set_license("GPL-2.0")

    add_urls("https://github.com/AviSynth/AviSynthPlus.git")

    add_versions("2026.01.01", "f2f4e318a5ba161d4945185f11c6a27e7aafa92b")

    add_deps("cmake")
    add_deps("ghc_filesystem")

    add_links("AviSynth")

    if on_check then
        on_check("android", function (package)
            assert(package:check_cxxsnippets({test = [[
                #include <cstdlib>
                void test() {
                    auto ptr = std::aligned_alloc(128, 128);
                }
            ]]}, {configs = {languages = "c++17"}}), "package(avisynthplus) Require at least C++17 (supports std::aligned_alloc).")
        end)
    end

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "NOMINMAX")
        end
    end)

    on_install("!wasm and !android and !cross", function (package)
        local configs = {"-DENABLE_PLUGINS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                IScriptEnvironment *env = CreateScriptEnvironment();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "avisynth/avisynth.h"}))
    end)
