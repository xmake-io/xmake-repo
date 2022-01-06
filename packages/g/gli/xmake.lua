package("gli")
    set_kind("library", {headeronly = true})
    set_homepage("https://gli.g-truc.net/")
    set_description("OpenGL Image (GLI)")

    set_urls("https://github.com/g-truc/gli/archive/$(version).tar.gz", 
             {version = function(version) return version:gsub("%+", ".") end})
    add_urls("https://github.com/g-truc/gli.git")
    add_versions("0.8.2.0", "a11067c7c457cfd0fb64fd330ce0308fbf222f731f6c8b500ebb6e69449fcc3f")

    add_deps("glm")

    if is_plat("linux") then
        add_syslinks("m")
    end

    on_install(function (package)
        os.rm("gli/CMakeLists.txt")
        io.writefile("xmake.lua", [[
            add_requires("glm")
            add_rules("mode.debug", "mode.release")
            target("gli")
                set_kind("headeronly")
                add_headerfiles("gli/(**.hpp)", "gli/(**.inl)", {prefixdir = "gli"})
                add_includedirs("gli", {public = true})
                add_rules("utils.install.cmake_importfiles")
                add_rules("utils.install.pkgconfig_importfiles")
        ]])

        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, config)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
              void test() {
                  gli::vec4 const Color(1.0f, 0.5f, 0.0f, 1.0f);
                  gli::texture2d Texture(gli::FORMAT_R16_SFLOAT_PACK16, gli::texture2d::extent_type(1), 1);
                  gli::detail::convertFunc<gli::texture2d, float, 1, gli::u16, gli::defaultp, gli::detail::CONVERT_MODE_HALF, true>::write(Texture, gli::texture2d::extent_type(0), 0, 0, 0, Color);
                  gli::vec4 Texel = gli::detail::convertFunc<gli::texture2d, float, 1, gli::u16, gli::defaultp, gli::detail::CONVERT_MODE_HALF, true>::fetch(Texture, gli::texture2d::extent_type(0), 0, 0, 0);
              }
        ]]}, {configs = {languages = "c++11"}, includes = {"gli/gli.hpp"}}))
    end)