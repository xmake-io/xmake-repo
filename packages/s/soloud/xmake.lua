package("soloud")
    set_description("SoLoud is an easy to use, free, portable c/c++ audio engine for games.")
    
    set_homepage("https://sol.gfxile.net/soloud/")
    set_license("zlib")
    
    add_urls("https://github.com/jarikomppa/soloud/archive/refs/tags/RELEASE_20200207.zip")
    add_versions("20200207", "ad3a6ee2020150e33e72911ce46bbfe26f9c84ec08ff8d7f22680ce4970f7fd3")
    
    -- linux needs to link with libpthread and libdl
    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end
    
    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            
            target("soloud")
                set_kind("$(kind)")
                set_languages("cxx11")
                
                -- for now we'll only support the miniaudio backend
                add_defines("WITH_MINIAUDIO")
                
                add_includedirs("include", {public = true})
                
                -- skip `tools` and `backend`
                add_files("src/**.cpp|tools/**.cpp|backend/**.cpp")
                add_files("src/**.c|tools/**.c|backend/**.c")
                -- compile the miniaudio backend
                -- hide the symbols from the included miniaudio
                -- to avoid conflicts with xrepo miniaudio.
                -- we can't use xrepo's miniaudio. it's too new (0.11.x versus 0.10.x).
                add_files("src/backend/miniaudio/*.c*", {symbols="hidden"})
                
                add_headerfiles("include/(**.h)")
        ]])
        
        import("package.tools.xmake").install(package)
    end)
    
    on_test(function (package)
        assert(package:has_cxxincludes("soloud.h"))
        assert(package:has_cxxtypes("SoLoud::Soloud", {includes = "soloud.h"}))
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                SoLoud::Soloud soloud;
            }
        ]]}, {includes = "soloud.h"}))
    end)
package_end()
