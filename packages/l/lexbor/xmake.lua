package("lexbor")
    set_homepage("https://github.com/lexbor/lexbor")
    set_description("Lexbor is development of an open source HTML Renderer library. https://lexbor.com")
    set_license("Apache-2.0")

    add_urls("https://github.com/lexbor/lexbor/archive/refs/tags/$(version).tar.gz",
             "https://github.com/lexbor/lexbor.git")

    add_versions("v2.6.0", "e9bb1aa8027ab92f11d5e8e6e7dc9b7bd632248c11a288eec95ade97bb7951a3")
    add_versions("v2.5.0", "d89060bb2fb6f7d0e0f399495155dd15e06697aa2c6568eab70ecd4a43084ba9")
    add_versions("v2.4.0", "8949744d425743828891de6d80327ccb64b5146f71ff6c992644e6234e63930e")
    add_versions("v2.2.0", "0583bad09620adea71980cff7c44b61a90019aa151d66d2fe298c679b554c57d")
    add_versions("v2.3.0", "522ad446cd01d89cb870c6561944674e897f8ada523f234d5be1f8d2d7d236b7")

    add_configs("thread", {description = "Build with Threads", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
        if is_plat("linux") then
            add_extsources("apt::liblexbor-dev")
        end
    elseif is_plat("macosx") then
        add_extsources("brew::lexbor")
    end

    on_install(function (package)
        local configs =
        {
            "-DLEXBOR_BUILD_EXAMPLES=OFF",
            "-DLEXBOR_BUILD_TESTS=OFF",
            "-DLEXBOR_BUILD_TESTS_CPP=OFF",
            "-DLEXBOR_INSTALL_HEADERS=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DLEXBOR_BUILD_SHARED=ON")
            table.insert(configs, "-DLEXBOR_BUILD_STATIC=OFF")
        else
            package:add("defines", "LEXBOR_STATIC")
            table.insert(configs, "-DLEXBOR_BUILD_SHARED=OFF")
            table.insert(configs, "-DLEXBOR_BUILD_STATIC=ON")
        end
        table.insert(configs, "-DLEXBOR_WITHOUT_THREADS=" .. (package:config("thread") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lxb_html_document_create", {includes = "lexbor/html/parser.h", {configs = {languages = "c99"}}}))
    end)
