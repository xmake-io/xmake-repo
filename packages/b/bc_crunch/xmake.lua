package("bc_crunch")
    set_homepage("https://github.com/Geolm/bc_crunch")
    set_description("tiny dependency-free lossless compressor for BC/DXT texture streams")
    set_license("zlib")

    add_urls("https://github.com/Geolm/bc_crunch.git")

    add_versions("1.5.2", "88f0a344acc1b2ce3cc1a8393f422aa1033c0539")

    on_install("*|*64*", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("bc_crunch")
                set_kind("$(kind)")
                add_files("bc_crunch.c")
                add_headerfiles("bc_crunch.h")
                if is_plat("windows", "mingw") and is_kind("shared") then
                    add_rules("utils.symbols.export_list", {symbols = {"crunch_min_size", "bc_crunch", "bc_decrunch"}})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void crunch(const void* input, uint32_t width, uint32_t height, void* output, size_t length) {
                size_t size = crunch_min_size();
                void* cruncher = malloc(size);
                bc_crunch(cruncher, input, width, height, bc1, output, length);
            }
            void decrunch(const void* input, size_t length, uint32_t width, uint32_t height, void* output) {
                bc_decrunch(input, length, width, height, bc1, output);
            }
        ]]}, {includes = "bc_crunch.h"}))
    end)
