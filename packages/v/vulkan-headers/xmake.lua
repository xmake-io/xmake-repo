package("vulkan-headers")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/KhronosGroup/Vulkan-Headers/")
    set_description("Vulkan Header files and API registry")
    set_license("Apache-2.0")
                    
    add_urls("https://github.com/KhronosGroup/Vulkan-Headers.git")
    add_urls("https://github.com/KhronosGroup/Vulkan-Headers/archive/$(version).tar.gz", {version = function (version)
        local prefix = "sdk-"
        if version:gt("1.3.261+1") then
            prefix = "vulkan-sdk-"
        end
        return version:startswith("v") and version or prefix .. version:gsub("%+", ".")
    end})

    add_configs("modules", {description = "Build with C++20 modules support.", default = false, type = "boolean"})

    -- when adding a new sdk version, please ensure vulkan-headers, vulkan-hpp, vulkan-loader, vulkan-tools, vulkan-validationlayers, vulkan-utility-libraries, spirv-headers, spirv-reflect, spirv-tools, glslang and volk packages are updated simultaneously
    add_versions("1.4.335+0", "269e95cc5138ea0a0d52fcb0ee19102add2560fedf5a43b1b5c17780c2775764")
    add_versions("1.4.309+0", "2bc1b4127950badc80212abf1edfa5c3b5032f3425edf37255863ba7592c1969")
    add_versions("1.3.290+0", "5b186e1492d97c44102fe858fb9f222b55524a8b6da940a8795c9e326ae6d722")
    add_versions("1.3.283+0", "cf54a812911b4e3e4ff15716c222a8fb9a87c2771c0b86060cb0ca2570ea55a9")
    add_versions("1.3.280+0", "14caa991988be6451755ad1c81df112f4b6f2bea05f0cf2888a52d4d0f0910f6")
    add_versions("1.3.275+0", "fcd2136a9feb0402820b334d8242773462cc47ed397aa20c8f4d04f7ea18d810")
    add_versions("1.3.268+0", "94993cbe2b1a604c0d5d9ea37a767e1aba4d771d2bfd4ddceefd66243095164f")
    add_versions("1.3.261+1", "7a25ebdb6325e626dc5d33bc937b289ccce7ddb7b0ac1a1b1d5d7ff33b6715d3")
    add_versions("1.3.250+1", "e5b563a415e73725bcf471b7e3e837804ed3703b47cce4553db5e7e73821c5ee")
    add_versions("1.3.246+1", "f9fa6a05ac1e059cd6f8f3a21705fb5bc093743d97315b7acf3bc20921abc27c")
    add_versions("1.3.239+0", "865fa8e8e8314fcca60777a92f50bd0cf612205a36e719d6975482d3366f619e")
    add_versions("1.3.236+0", "2df85b3daa78ced7f910db870ea2aed10f718c703e18076b4549ca4005c9c451")
    add_versions("1.3.231+1", "6e16051ccb28821b907a08025eedb82cc73e1056924b32f75880ecae2499f7f6")
    add_versions("1.3.211+0", "c464bcdc24b7541ac4378a270617a23d4d92699679a73f95dc4b9e1da924810a")
    add_versions("1.2.198+0", "34782c61cad9b3ccf2fa0a31ec397d4fce99490500b4f3771cb1a48713fece80")
    add_versions("1.2.189+1", "ce2eb5995dddd8ff2cee897ab91c30a35d6096d5996fc91cec42bfb37112d3f8")
    add_versions("1.2.182+0", "61c05dc8a24d5a9104ca2cd233cb9febc3455d69a64e404c3535293f3a463d02")
    add_versions("1.2.162+0", "eb0f6a79ac38e137f55a0e13641140e63b765c8ec717a65bf3904614ef754365")
    add_versions("1.2.154+0", "a0528ade4dd3bd826b960ba4ccabc62e92ecedc3c70331b291e0a7671b3520f9")

    on_load(function (package)
        if not package:config("modules") then
            package:add("deps", "cmake")
            if package:is_plat("mingw") and is_subhost("msys") then
                package:add("extsources", "pacman::vulkan-headers")
            elseif package:is_plat("linux") then
                package:add("extsources", "apt::libvulkan-dev")
            elseif package:is_plat("macosx") then
                package:add("extsources", "brew::vulkan-headers")
            end
        end
    end)

    on_install(function (package)
        if not package:config("modules") then
            import("package.tools.cmake").install(package, {
                "-DVULKAN_HEADERS_ENABLE_MODULE=OFF",
                "-DVULKAN_HEADERS_ENABLE_TESTS=OFF"
            })
        else
            io.writefile("xmake.lua", [[ 
                target("vulkan-headers")
                    set_kind("static")
                    set_languages("c++20")
                    add_headerfiles("include/(**.h)")
                    add_headerfiles("include/(**.hpp)")
                    add_includedirs("include")
                    add_files("include/**.cppm", {public = true})
            ]])
            local configs = {}
            import("package.tools.xmake").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test() {
                int version = VK_HEADER_VERSION;
            }
        ]]}, {includes = "vulkan/vulkan.h"}))
    end)
