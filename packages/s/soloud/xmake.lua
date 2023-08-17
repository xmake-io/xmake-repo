package("soloud")
    set_description("SoLoud is an easy to use, free, portable c/c++ audio engine for games.")
    set_homepage("https://github.com/jarikomppa/soloud")
    set_license("zlib")
    
    add_urls("https://github.com/jarikomppa/soloud/archive/refs/tags/RELEASE_$(version).zip",
         {version = function (version) return version:gsub("%.", "") end})
    add_versions("2020.02.07", "ad3a6ee2020150e33e72911ce46bbfe26f9c84ec08ff8d7f22680ce4970f7fd3")
    
    -- for now we only support the miniaudio backend
    add_deps("miniaudio")
    add_patches("2020.02.07", path.join(os.scriptdir(), "patches", "miniaudio_v11.patch"), "d98b6727a159c3dccd45de872b321a1c180bc353af08d4bdce4e298f4de14f21")
    
    -- linux needs to link with libpthread and libdl
    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end
    
    on_install(function (package)
        -- remove the miniaudio.h that comes with soloud. we have it as an xrepo dependency.
        os.rm("src/backend/miniaudio/miniaudio.h")
        
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            
            add_requires("miniaudio")
            
            target("soloud")
                set_kind("$(kind)")
                set_languages("cxx11")
                
                -- for now we'll only support the miniaudio backend
                add_defines("WITH_MINIAUDIO")
                add_packages("miniaudio")
                
                add_includedirs("include", {public = true})
                
                -- skip `tools` and `backend`
                add_files("src/**.cpp|tools/**.cpp|backend/**.cpp")
                add_files("src/**.c|tools/**.c|backend/**.c")
                -- compile the miniaudio backend
                add_files("src/backend/miniaudio/*.c*")
                
                add_headerfiles("include/(**.h)")
        ]])
        
        import("package.tools.xmake").install(package)
    end)
    
    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                SoLoud::Soloud soloud;
            }
        ]]}, {includes = "soloud.h"}))
    end)
package_end()
