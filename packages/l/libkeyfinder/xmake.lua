package("libkeyfinder")
    set_homepage("https://mixxxdj.github.io/libkeyfinder/")
    set_description("Musical key detection for digital audio, GPL v3")
    set_license("GPL-3.0")

    add_urls("https://github.com/mixxxdj/libkeyfinder/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mixxxdj/libkeyfinder.git")

    add_versions("2.2.8", "a54fc6c5ff435bb4b447f175bc97f9081fb5abf0edd5d125e6f5215c8fff4d11")

    add_deps("cmake", "fftw")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                KeyFinder::AudioData inputAudio;
                inputAudio.setChannels(1);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "keyfinder/keyfinder.h"}))
    end)
