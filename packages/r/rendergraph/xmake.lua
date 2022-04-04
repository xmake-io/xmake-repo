package("rendergraph")

    set_homepage("https://github.com/DragonJoker/RenderGraph/")
    set_description("Vulkan render graph management library. .")

    set_urls("https://github.com/DragonJoker/RenderGraph.git")
    add_versions("1.0", "61e814bb0298983eae853d9ba5386a272ebc1eb9")

    add_deps("vulkan-headers")

    add_links("RenderGraph")

    on_install("windows|x64", "macosx", "linux", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("vulkan-headers")
            target("RenderGraph")
                set_kind("shared")
                add_includedirs("include")
                add_files("source/RenderGraph/RunnablePasses/*.cpp")
                add_files("source/RenderGraph/*.cpp")
                set_languages("c++20")
                add_defines("RenderGraph_EXPORTS")
                add_headerfiles("include/RenderGraph/RunnablePasses/*.hpp", {prefixdir="RenderGraph/RunnablePasses"})
                add_headerfiles("include/RenderGraph/*.hpp", {prefixdir="RenderGraph"})
                add_packages("vulkan-headers")
        ]])
        import("package.tools.xmake").install(package)
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
