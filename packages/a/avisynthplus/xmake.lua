package("avisynthplus")
    set_homepage("http://avs-plus.net")
    set_description("AviSynth with improvements")
    set_license("GPL-2.0")

    add_urls("https://github.com/AviSynth/AviSynthPlus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AviSynth/AviSynthPlus.git")

    add_versions("2026.01.01", "f2f4e318a5ba161d4945185f11c6a27e7aafa92b")

    add_deps("cmake")
    add_deps("ghc_filesystem")

    on_install(function (package)
        local configs = {"-DENABLE_PLUGINS=OFF"}
        if package:is_plat("wasm") then
            io.replace("CMakeLists.txt", "-msse2", "-msimd128 -msse2", {plain = true})
        end
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
