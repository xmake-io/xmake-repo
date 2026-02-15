package("vk-bootstrap")
    set_homepage("https://github.com/charles-lunarg/vk-bootstrap")
    set_description("Vulkan Bootstrapping Iibrary.")
    set_license("MIT")

    add_urls("https://github.com/charles-lunarg/vk-bootstrap/archive/refs/tags/$(version).tar.gz",
             "https://github.com/charles-lunarg/vk-bootstrap.git")

    add_versions("v1.4.325", "82711742cc1f2f7eb25048dd9af154386cd083a9ec6e9afd9e7abd197b0b5523")
    add_versions("v1.4.315", "f28595b057e10033cc6b64319e76be4eeda5b7c9ee83cc1808218e69b040f353")
    add_versions("v1.4.312", "9bc21aea86859329e9939d4d44f40ef4ce9e2208a3fdd9cb67e2d2f0f2393814")
    add_versions("v1.4.311", "baa67974690be6fd50919e381c775ac172d6b790c152e3cfd4be37ec64aa02d8")
    add_versions("v1.4.307", "b7d1b0868de16244cb666b0777ab62a38c6d99c29b85ef33be8ce36005cd0732")
    add_versions("v1.3.302", "3b7eb60443cb7c8a334d7a76766e8f703d9e81b43fa8b5bd2983578cbb373970")
    add_versions("v1.3.295", "fff665c8675a7730777279ad9caba8c229d7fc79f35a9dad52873d1fa598b495")
    add_versions("v1.3.292", "0853ab291ab7b19779582ada1d6a245dcd0489c2e346ee1e4275c24d3788077a")
    add_versions("v1.3.290", "225f61c850f4d2e242121249418db2f54b09cd799922547bdb3f6d9c00738fa8")
    add_versions("v1.3.289", "101c4b10aaf48f07c5aae955fab12d8a453970c13fa93e8fe5e5b0b58ea1ceac")
    add_versions("v1.3.285", "c86b12ac2a0a809f7bf2af009a612be188aa4bb3a669d5955b22007989b3e07c")
    add_versions("v1.3.284", "753a7cc337ae7dcfcbfad1547c010287fd4bec1237bf17f35349470c7430830c")
    add_versions("v1.3.283", "1e6e43b76c14fa544d057b3e4825817e1aed50c3a2efbaf94862340c6304dc24")
    add_versions("v1.3.282", "80aba4c2903e7f7f54a43d4c41dd6e2014b79c26fa432c417efb566e8b42fe67")
    add_versions("v0.5", "7ec1017d71d48595c078a4488140b230fd9cad1059986a18a507f356bf00e89b")
    add_versions("v0.6", "95dedaa5cedf7a271f051d91b24b3b6c78aa3c5b2bc3cf058554c92748a421b2")
    add_versions("v0.7", "7b2c30a4c46514cc5b20d2bebab25c495df39574b9e117c760d1cfe19f71d9aa")
    add_versions("v1.3.268", "028300b0dac2dfaf193ca95d2ecd46a450f6da31095a09334c4c3b76c561714c")
    add_versions("v1.3.275", "33737a731e8b3a4539812e63502ea55dffb3dbc7331b44c4cc0902fbf797f5ff")
    add_versions("v1.3.280", "0b8b434b4d02a4ace9238acdd403c4c7993957176182c45bd8f0c1225733a599")

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
                add_headerfiles("src/VkBootstrapFeatureChain.h")
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
