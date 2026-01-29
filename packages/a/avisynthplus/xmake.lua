package("avisynthplus")
    set_homepage("http://avs-plus.net")
    set_description("AviSynth with improvements")

    add_urls("https://github.com/AviSynth/AviSynthPlus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AviSynth/AviSynthPlus.git")

    add_versions("v3.7.5", "2533fafe5b5a8eb9f14d84d89541252a5efd0839ef62b8ae98f40b9f34b3f3d5")

    add_deps("cmake")
    add_deps("ghc_filesystem")

    on_install(function (package)
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
