package("simdjson")

    set_homepage("https://simdjson.org")
    set_license("Apache 2.0")
    set_description("Ridiculously fast JSON parsing, UTF-8 validation and JSON minifying for popular 64 bit systems.")

    set_urls("https://github.com/simdjson/simdjson.git")
    add_versions("0.8.2", "61c8cfa07deb7625bb0e6b80dbceb42edd4bf387")

    add_configs("threads",      { description = "Enable threads.",     default = true,  type = "boolean"})
    add_configs("noexceptions", { description = "Disable exceptions.", default = false, type = "boolean"})
    add_configs("logging",      { description = "Enable logging.",     default = false, type = "boolean"})
    
    on_install("windows|x64", "mingw|x86_64", "macosx|x86_64", "linux|x86_64", "linux|arm64", "iphoneos|arm64", function(package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        configs.threads = package:config("threads")
        configs.noexceptions = package:config("noexceptions")
        configs.logging = package:config("logging")

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({ test = [[
                simdjson::dom::parser parser;
        ]]}, { configs = { languages = "c++17" }, includes = "simdjson.h" })
        , "Could not compile a test C++ snippet.")
    end)
    
