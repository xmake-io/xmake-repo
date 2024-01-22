package("vk-bootstrap")
    set_homepage("https://github.com/charles-lunarg/vk-bootstrap")
    set_description("Vulkan Bootstrapping Iibrary.")
    set_license("MIT")

    add_urls("https://github.com/charles-lunarg/vk-bootstrap/archive/refs/tags/$(version).tar.gz",
             "https://github.com/charles-lunarg/vk-bootstrap.git")

    add_versions("v0.5", "7ec1017d71d48595c078a4488140b230fd9cad1059986a18a507f356bf00e89b")
    add_versions("v0.6", "95dedaa5cedf7a271f051d91b24b3b6c78aa3c5b2bc3cf058554c92748a421b2")
    add_versions("v0.7", "7b2c30a4c46514cc5b20d2bebab25c495df39574b9e117c760d1cfe19f71d9aa")
    add_versions("v1.3.268", "028300b0dac2dfaf193ca95d2ecd46a450f6da31095a09334c4c3b76c561714c")
    add_versions("v1.3.275", "33737a731e8b3a4539812e63502ea55dffb3dbc7331b44c4cc0902fbf797f5ff")

    add_deps("vulkan-headers")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_syslinks("dl")
    end

    on_install("windows", "linux", "macosx", function (package)
        local version = package:version()
        local language_version
        if not version or version:ge("1.3.270") then
            language_version = "cxx17"
        else
            language_version = "cxx14"
        end
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("vulkan-headers")
            target("vk-bootstrap")
                set_kind("static")
                ]] .. "set_languages(\"" .. language_version .. "\")" .. [[
                add_files("src/VkBootstrap.cpp")
                add_headerfiles("src/VkBootstrap.h")
                add_headerfiles("src/VkBootstrapDispatch.h")
                add_packages("vulkan-headers")
                if is_plat("linux") then
                    add_syslinks("dl")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        local configs = {}
        local version = package:version()
        if not version or version:ge("1.3.270") then
            configs.languages = "cxx17"
        else
            configs.languages = "cxx14"
        end
        assert(package:check_cxxsnippets({test = [[
            vkb::InstanceBuilder builder;
            auto inst_ret = builder.set_app_name ("Example Vulkan Application")
                        .request_validation_layers ()
                        .use_default_debug_messenger ()
                        .build ();
        ]]}, {configs = configs, includes = "VkBootstrap.h"}))
    end)
