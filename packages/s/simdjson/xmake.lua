package("simdjson")

    set_homepage("https://simdjson.org")
    set_description("Ridiculously fast JSON parsing, UTF-8 validation and JSON minifying for popular 64 bit systems.")
    set_license("Apache-2.0")

    add_urls("https://github.com/simdjson/simdjson/archive/refs/tags/$(version).tar.gz",
             "https://github.com/simdjson/simdjson.git")
    add_versions("v0.9.5", "db69582fc5e4ece8c0a6a64894efeef475fe22fe466bd67195422de11b08b4d2")
    add_versions("v0.9.7", "a21279ae4cf0049234a822c5c3550f99ec1707d3cda12156d331dcc8cd411ba0")
    add_versions("v1.0.0", "fe54be1459b37e88abd438b01968144ed4774699d1272dd47a790b9362c5df42")
    add_versions("v1.1.0", "9effcb21fe48e4bcc9b96031e60c3911c58aa656ad8c78212d269c0db9e0133e")
    add_versions("v3.0.0", "e6dd4bfaad2fd9599e6a026476db39a3bb9529436d3508ac3ae643bc663526c5")
    add_versions("v3.1.1", "4fcb1c9b1944e2eb8a4a4a22c979e2827165216f859e94d93c846c1261e0e432")

    add_configs("threads",      { description = "Enable threads.",     default = true,  type = "boolean"})
    add_configs("noexceptions", { description = "Disable exceptions.", default = false, type = "boolean"})
    add_configs("logging",      { description = "Enable logging.",     default = false, type = "boolean"})

    on_load("windows|x64", function (package)
        if package:config("shared") then
            package:add("defines", "SIMDJSON_USING_WINDOWS_DYNAMIC_LIBRARY")
        end
    end)

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
            void test() {
                simdjson::dom::parser parser;
            }
        ]]}, { configs = { languages = "c++17" }, includes = "simdjson.h" })
        , "Could not compile a test C++ snippet.")
    end)
