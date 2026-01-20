package("floatengine")
    set_homepage("https://github.com/Fls-Float/FloatEngine")
    set_description("A high-performance, cross-platform C++ game engine.")
    set_license("MIT")

    add_urls("https://github.com/fls-float/FloatEngine.git")

    add_versions("2025.12.20", "d3754c2b8235fe1920aea65cfd7cd9247c758408")

    add_patches("2025.12.20", "patches/2025.12.20/cleanup.patch", "55ba6f8e4fa3855d9e998d381a148cf31a977e99174c27a33753095275994cc5")
    add_patches("2025.12.20", "patches/2025.12.20/fix-include.patch", "6bb236de206b6b4b0773a03007acae8095e215a54f5add9279446a4c0613703b")
    add_patches("2025.12.20", "patches/2025.12.20/fix-mingw-gcc15.patch", "252675e4f9b0f9531efb4243fe5819edb1aa9ea13d0b422904d07347041d276c")
    add_patches("2025.12.20", "patches/2025.12.20/fix-template.patch", "66450b0e49549d602e7436d234b46af83e779778398b4d2bb4fc9b5376143388")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("minizip-ng", {configs = {bzip2 = true}})
    add_deps("lua", "libcurl", "slikenet", "nlohmann_json", "nativefiledialog-extended", "sol2")
    add_deps("fls-float-raylib", "fls-float-rlimgui")

    if is_plat("windows", "mingw") then
        add_syslinks("user32", "kernel32", "ws2_32", "iphlpapi")
    end

    on_install("windows", "mingw", function (package)
        os.rmdir("FloatEngine/gui")
        io.writefile("xmake.lua", [[
            set_languages("c11", "c++17")
            add_rules("mode.release", "mode.debug")
            add_requires("minizip-ng", {configs = {bzip2 = true}})
            add_requires("lua", "libcurl", "slikenet", "nlohmann_json", "nativefiledialog-extended", "sol2")
            add_requires("fls-float-raylib",  "fls-float-rlimgui")
            add_packages("minizip-ng", "lua", "libcurl", "slikenet", "nlohmann_json", "nativefiledialog-extended", "sol2")
            add_packages("fls-float-raylib",  "fls-float-rlimgui")
            set_encodings("utf-8")
            target("floatengine")
                set_kind("$(kind)")
                add_files("FloatEngine/*.cpp",
                          "FloatEngine/*.c")
                add_headerfiles("(FloatEngine/*.h)",
                                "(FloatEngine/*.hpp)")
                add_includedirs("FloatEngine")
                add_syslinks("user32", "kernel32", "ws2_32", "iphlpapi")
                add_defines("WIN32_LEAN_AND_MEAN", "NOMINMAX")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Sprite sprite = Sprite();
                size_t w = sprite.FrameCount();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "FloatEngine/Sprite.h"}))
    end)
