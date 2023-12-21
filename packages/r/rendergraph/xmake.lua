package("rendergraph")

    set_homepage("https://github.com/DragonJoker/RenderGraph/")
    set_description("Vulkan render graph management library. .")
    set_license("MIT")

    set_urls("https://github.com/DragonJoker/RenderGraph/archive/refs/tags/$(version).tar.gz",
         "https://github.com/DragonJoker/RenderGraph.git")
    add_versions("v1.3.0", "b9c68b6949c7b60ffb49f9b9997432aac5baec69")
    add_versions("v1.2.0", "3f434cc347048656f02bfb87b0ce69ac02b9b18af4262d221c0d4b0ecf1b7bae")
    add_versions("v1.1.0", "b2fb87cdc0cdec94d4e2a9139533e5f72c0fadfe090c085308edbb84084b4a0c")
    add_versions("v1.0.0", "73814e89f854adb1287c33ea8d89f56ef7822977b5e974218a9a826d76a18e67")

    add_deps("vulkan-headers")

    add_links("RenderGraph")

    on_install("windows|x64", "macosx", "linux", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("vulkan-headers")
            target("RenderGraph")
                set_kind("$(kind)")
                add_includedirs("include")
                add_files("source/RenderGraph/**.cpp")
                set_languages("c++20")
                if is_plat("windows") then
                    if is_kind("shared") then
                        add_defines("RenderGraph_EXPORTS")
                    else
                        add_defines("CRG_BUILD_STATIC")
                    end
                end
                add_headerfiles("include/(RenderGraph/**.hpp)")
                add_packages("vulkan-headers")
        ]])
        local configs = {}
        if package:config("shared") then 
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            static void test()
            {
                crg::ResourceHandler handler;
                crg::FrameGraph graph{ handler, "test" };
            }
        ]]}, {configs = {languages = "cxx20"},
            includes = {
                "RenderGraph/FrameGraph.hpp",
                "RenderGraph/ResourceHandler.hpp"}}))
    end)
