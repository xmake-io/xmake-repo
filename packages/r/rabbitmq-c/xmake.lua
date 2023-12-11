package("rabbitmq-c")

    set_homepage("https://github.com/alanxz/rabbitmq-c")
    set_description("This is a C-language AMQP client library for use with v2.0+ of the RabbitMQ broker.")

    set_urls("https://github.com/alanxz/rabbitmq-c/archive/refs/tags/$(version).zip",
             "https://github.com/alanxz/rabbitmq-c.git")

    add_versions("v0.11.0", "fad876075cbcf9a2f3dff27be66391f69117d5068529ba1d53e67fe59c2d88e1")

    add_deps("cmake")
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean"})
    add_configs("tools", {description = "Build the command line tools.", default = false, type = "boolean"})
    add_configs("ssl", {description = "Build rabbitmq-c with SSL support.", default = false, type = "boolean"})

    on_install(function (package)
        local configs = {"-DBUILD_EXAMPLES=OFF", "-DBUILD_TESTS=OFF"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DBUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_SSL_SUPPORT=" .. (package:config("ssl") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_load(function (package)
        if package:config("ssl") then
            package:add("deps", "openssl")
        end
        if package:config("tools") then
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test()
            {
                const char* version = amqp_version();
            }
        ]]}, {configs = {languages = "c++98"}, includes = { "amqp.h"} }))
    end)
