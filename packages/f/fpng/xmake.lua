package("fpng")
    set_homepage("https://github.com/richgel999/fpng")
    set_description("Super fast C++ .PNG writer/reader")

    add_urls("https://github.com/richgel999/fpng/archive/refs/tags/$(version).tar.gz",
	     "https://github.com/richgel999/fpng.git")
    add_versions("v1.0.6", "0f4b60f0b638d47addfbd150bb19bfe2f3343c4ed2d742c02c085456de0ee1dd")
    add_versions("v1.0.1", "ef4e7ee23176908fdad4936f05f3ad097abaf61485171e108fb1e7ff230bd523")

    add_configs("sse4", { description = "Enable SSE 4.1 support.", default = false, type = "boolean"})

    on_install("windows", "linux", "macosx", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            option("sse4", {showmenu = true, default = false})
            target("fpng")
                set_kind("$(kind)")
                add_files("src/fpng.cpp")
                add_headerfiles("src/fpng.h")
                if has_config("sse4") then
                    add_defines("FPNG_NO_SSE=0")
                    add_cxflags("-msse4.1", "-mpclmul")
                else
                    add_defines("FPNG_NO_SSE=1")
                end
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        local configs = {sse4 = package:config("sse4")}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                std::vector<uint8_t> fpng_file_buf;
	 	fpng::fpng_encode_image_to_memory(0, 0, 0, 0, fpng_file_buf, 0);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "fpng.h"}))
    end)
