package("xz-embedded")
    set_homepage("https://tukaani.org/xz/embedded.html")
    set_description("XZ Embedded")
    set_license("0BSD")

    add_urls("https://github.com/tukaani-project/xz-embedded.git")
    add_versions("2024.12.30", "ae63ae3a36ed01724674e8f3d750dc47bf125410")

    on_install(function (package)
        os.cd("userspace")
        local configs = {}
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                xz_crc32_init();
            }
        ]]}, {configs = {languages = "c11"}, includes = "xz.h"}))
    end)
