package("basisu")
    set_homepage("https://github.com/BinomialLLC/basis_universal")
    set_description("Basis Universal GPU Texture Codec")
    set_license("Apache-2.0")

    add_urls("https://github.com/BinomialLLC/basis_universal/archive/refs/tags/$(version).tar.gz",
             "https://github.com/BinomialLLC/basis_universal.git")

    add_versions("1.16.4", "e5740fd623a2f8472c9700b9447a8725a6f27d65b0b47c3e3926a60db41b8a64")

    add_configs("opencl", {description = "Enable opencl", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    end

    add_deps("zstd")

    on_load(function (package)
        if package:config("opencl") then
            package:add("deps", "opencl")
        end
    end)

    on_install(function (package)
        io.replace("encoder/basisu_comp.cpp", "../zstd/zstd.h", "zstd.h", {plain = true})

        local configs = {
            opencl = package:config("opencl"),
            tools = package:config("tools"),
        }
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                basist::basisu_transcoder_init();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "basisu/transcoder/basisu_transcoder.h"}))
    end)
