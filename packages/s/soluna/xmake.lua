package("soluna")
    set_homepage("https://github.com/cloudwu/soluna")
    set_description("A simple 2d game framework")
    set_license("MIT")

    add_urls("https://github.com/cloudwu/soluna.git")
    add_versions("2025.03.04", "f47f60875ff8900b69d65635ac51eb6bef55f2a0")

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        for _, sourcefile in ipairs(os.files("src/*.c")) do
            io.replace(sourcefile, "\"sokol/", "\"", {plain = true})
        end
        for _, headerfile in ipairs(os.files("src/*.h")) do
            io.replace(headerfile, "#include <stdint.h>",
                "#include <stdint.h>\n#include <stddef.h>", {plain = true})
        end
        io.replace("src/file.c", "#include <string.h>",
            "#include <string.h>\n#include <stdlib.h>", {plain = true})
        os.rm("3rd/lua", "3rd/sokol", "3rd/stb", "3rd/datalist")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
    end)
