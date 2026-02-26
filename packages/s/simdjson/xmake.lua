package("simdjson")

    set_homepage("https://simdjson.org")
    set_description("Ridiculously fast JSON parsing, UTF-8 validation and JSON minifying for popular 64 bit systems.")
    set_license("Apache-2.0")

    add_urls("https://github.com/simdjson/simdjson/archive/refs/tags/$(version).tar.gz",
             "https://github.com/simdjson/simdjson.git")
    add_versions("v4.2.4", "6f942d018561a6c30838651a386a17e6e4abbfc396afd0f62740dea1810dedea")
    add_versions("v4.2.2", "3efae22cb41f83299fe0b2e8a187af543d3dda93abbb910586f897df670f9eaa")
    add_versions("v4.2.1", "72c60a0fa6871073a4a458e80947dd75894fa1ff69550c7c77f9f4e695dff7f1")
    add_versions("v4.2.0", "cf294f624bab25d6e48f2c5380192f839055a7c0e82a77b454f5fcefdb02d07f")
    add_versions("v4.1.0", "78115e37b2e88ec63e6ae20bb148063a9112c55bcd71404c8572078fd8a6ac3e")
    add_versions("v4.0.7", "d2d15490605858d3dd42e90d25e0fde31c53446b7d3cde9ef334449236927916")
    add_versions("v4.0.6", "84b90eaff91c8a4ac40feff1fffa9d13d706f914413dd41351644038a14079b6")
    add_versions("v3.12.3", "d0af071f2f4187d8b26b556e83ef832b634bd5feb4e2f537b9dabbd334d4e334")
    add_versions("v3.12.2", "8ac7c97073d5079f54ad66d04381ec75e1169c2e20bfe9b6500bc81304da3faf")
    add_versions("v3.11.3", "eeb10661047e476aa3b535d14a32af95690691778d7afe0630a344654ff9759a")
    add_versions("v3.11.2", "47a6d78a70c25764386a01b55819af386b98fc421da79ae8de3ae0242cf66d93")
    add_versions("v3.10.1", "1e8f881cb2c0f626c56cd3665832f1e97b9d4ffc648ad9e1067c134862bba060")
    add_versions("v3.10.0", "9c30552f1dd0ee3d0832bb1c6b7b97d813b18d5ef294c10dcb6fc242e5947de8")
    add_versions("v3.9.5", "3d9e894a0ded85c000ec5b6ed1450ab4b037f44ba95eb3b0fefb4cda72cd9dab")
    add_versions("v3.9.4", "9bf13be00fa1e1c5891a90dbc39b983e09972f0972a8956c20a9974cedfcca2f")
    add_versions("v3.9.3", "2e3d10abcde543d3dd8eba9297522cafdcebdd1db4f51b28f3bc95bf1d6ad23c")
    add_versions("v3.9.2", "79fbe700f4ac3dd69c4f08275af58399daabd612bca0c0465aea959c60256651")
    add_versions("v3.9.1", "a4b6e7cd83176e0ccb107ce38521da40a8df41c2d3c90566f2a0af05b0cd05c4")
    add_versions("v3.8.0", "e28e3f46f0012d405b67de6c0a75e8d8c9a612b0548cb59687822337d73ca78b")
    add_versions("v3.7.0", "27315c4861893b3e036c1f672b1c238ee86be6edb84c0824d1ed20dea5999777")
    add_versions("v3.6.0", "9eab3197231382b8b99d14d8ca647d6ab6bea1b40008df086d25e6f687309bf6")
    add_versions("v3.1.1", "4fcb1c9b1944e2eb8a4a4a22c979e2827165216f859e94d93c846c1261e0e432")
    add_versions("v3.0.0", "e6dd4bfaad2fd9599e6a026476db39a3bb9529436d3508ac3ae643bc663526c5")
    add_versions("v1.1.0", "9effcb21fe48e4bcc9b96031e60c3911c58aa656ad8c78212d269c0db9e0133e")
    add_versions("v1.0.0", "fe54be1459b37e88abd438b01968144ed4774699d1272dd47a790b9362c5df42")
    add_versions("v0.9.7", "a21279ae4cf0049234a822c5c3550f99ec1707d3cda12156d331dcc8cd411ba0")
    add_versions("v0.9.5", "db69582fc5e4ece8c0a6a64894efeef475fe22fe466bd67195422de11b08b4d2")

    add_configs("threads",      { description = "Enable threads.",     default = true,  type = "boolean"})
    add_configs("noexceptions", { description = "Disable exceptions.", default = false, type = "boolean"})
    add_configs("logging",      { description = "Enable logging.",     default = false, type = "boolean"})

    on_load("windows|x64", function (package)
        if package:config("shared") then
            package:add("defines", "SIMDJSON_USING_WINDOWS_DYNAMIC_LIBRARY")
        end
    end)

    on_install("windows|x64", "mingw|x86_64", "macosx|x86_64", "macosx|arm64", "linux|x86_64", "linux|arm64", "iphoneos|arm64", function(package)
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
