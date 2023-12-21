package("vk-bootstrap")
    set_homepage("https://github.com/charles-lunarg/vk-bootstrap")
    set_description("Vulkan Bootstrapping Iibrary.")
    set_license("MIT")

    add_urls("https://github.com/charles-lunarg/vk-bootstrap/archive/refs/tags/$(version).tar.gz",
             "https://github.com/charles-lunarg/vk-bootstrap.git")

    add_versions("v0.5", "7ec1017d71d48595c078a4488140b230fd9cad1059986a18a507f356bf00e89b")
    add_versions("v0.6", "95dedaa5cedf7a271f051d91b24b3b6c78aa3c5b2bc3cf058554c92748a421b2")
    add_versions("v0.7", "7b2c30a4c46514cc5b20d2bebab25c495df39574b9e117c760d1cfe19f71d9aa")

    add_deps("vulkan-headers")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_syslinks("dl")
    end

    on_install("windows", "linux", "macosx", function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_requires("vulkan-headers")
            target("vk-bootstrap")
                set_kind("static")
                set_languages("cxx14")
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
        assert(package:check_cxxsnippets({test = [[
            vkb::InstanceBuilder builder;
            auto inst_ret = builder.set_app_name ("Example Vulkan Application")
                        .request_validation_layers ()
                        .use_default_debug_messenger ()
                        .build ();
        ]]}, {configs = {languages = "cxx14"}, includes = "VkBootstrap.h"}))
    end)
