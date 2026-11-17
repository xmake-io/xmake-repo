package("llm-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Mattbusel/llm-cpp")
    set_description("26 single-header C++17 libraries for LLM apps: streaming, retries, caching, cost estimates, RAG, structured JSON and agents")
    set_license("MIT")

    add_urls("https://github.com/Mattbusel/llm-cpp/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/Mattbusel/llm-cpp.git")

    add_versions("1.2.0", "08cda58c29ea66f392d03e15c674f1ab47e7c75f33a36f0dd5617beed1c1db72")
    add_versions("1.1.0", "64fd86d101d8ccbcefd9ac41aaf067ef2294de77c18d8746f0c267d14d1e71ca")

    add_configs("curl", {description = "Link libcurl, needed by the network headers (ab, agent, audio, batch, chat, embed, eval, finetune, rag, rank, stream, vision).", default = false, type = "boolean"})

    on_load(function (package)
        -- code written against the single-file repos includes "llm_cache.hpp" directly
        package:add("includedirs", "include", "include/llm")
        if package:config("curl") then
            package:add("deps", "libcurl")
        end
        if package:is_plat("linux", "bsd") then
            package:add("syslinks", "pthread")
        end
    end)

    on_install(function (package)
        os.cp("include/llm/*.hpp", package:installdir("include/llm"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #define LLM_COST_IMPLEMENTATION
            #include <llm/llm_cost.hpp>
            void test() {
                llm::TokenCount tc = llm::count("Hello", llm::models::GPT4O_MINI);
                const llm::Model* m = llm::find_model("deepseek-chat");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
