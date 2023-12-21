package("rsm-autotoml")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Ryan-rsm-McKenzie/AutoTOML")
    set_description("toml++ wrapper for basic node types")
    set_license("MIT")

    add_urls("https://github.com/Ryan-rsm-McKenzie/AutoTOML.git")
    add_versions("2020.12.29", "10db32f275479a5af15793358e9e9e84079d13b3")

    add_deps("toml++")

    on_install(function (package)
        io.replace("include/AutoTOML.hpp", "string_t = toml::string", "string_t = std::string", {plain = true})
        io.replace("include/AutoTOML.hpp", "~ISetting() = 0 {}", "~ISetting() = default;", {plain = true})
        io.replace("include/AutoTOML.hpp", "node.as<", "node.template as<", {plain = true})
        os.cp("include/AutoTOML.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                static AutoTOML::bSetting test{ "section", "key", true };
            }
        ]]}, {configs = {languages = "c++17"}, includes = "AutoTOML.hpp"}))
    end)
