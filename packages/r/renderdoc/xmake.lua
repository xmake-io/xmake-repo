package("renderdoc")
    set_homepage("https://renderdoc.org/")
    set_description("RenderDoc In-Application API")
    set_license("MIT")

    -- x86 Windows' archive download URL format: https://renderdoc.org/stable/{version}/RenderDoc_{version}_32.zip
    -- x64 Windows' archive download URL format: https://renderdoc.org/stable/{version}/RenderDoc_{version}_64.zip
    -- x64 Linux's archive download URL format:  https://renderdoc.org/stable/{version}/renderdoc_{version}.tar.gz
    if is_plat("windows") and is_arch("x64") then
        add_urls("https://renderdoc.org/stable/$(version)/RenderDoc_$(version)_64.zip")
        add_versions("1.42", "1448d896d43904f50c1496df9a8d015553e0449ee107bac9b97359f2dffe373d")
    elseif is_plat("windows") and is_arch("x86") then
        add_urls("https://renderdoc.org/stable/$(version)/RenderDoc_$(version)_32.zip")
        add_versions("1.42", "dcdd159c53cd8ec1d31d562150e49d927734a01297375e0876949347e1c9a09e")
    else
        add_urls("https://renderdoc.org/stable/$(version)/renderdoc_$(version).tar.gz")
        add_versions("1.42", "25e66e1d35bff7a31a139f2c0b47f510947e782859dbfbbfd0450eca60bc16d2")
    end

    add_includedirs("include")
    add_linkdirs("lib")

    on_install("windows", function (package)
        os.cp("renderdoc_app.h", package:installdir("include"))
        os.cp("lib/librenderdoc.dll", package:installdir("lib"))
    end)

    on_install("linux", function (package)
        os.cp("include/renderdoc_app.h", package:installdir("include"))
        os.cp("lib/librenderdoc.so", package:installdir("lib"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <renderdoc_app.h>

            #ifdef defined(_WIN64) || defined(_WIN32)
                #include <windows.h>
            #else
                #include <dlfcn.h>
            #endif

            void test() {
                RENDERDOC_API_1_0_0* api = nullptr;
                
                pRENDERDOC_GetAPI RENDERDOC_GetAPI = nullptr;
                #if defined(_WIN64) || defined(_WIN32)
                    if(HMODULE mod = GetModuleHandleA("renderdoc.dll")) {
                        pRENDERDOC_GetAPI RENDERDOC_GetAPI = (pRENDERDOC_GetAPI) GetProcAddress(mod, "RENDERDOC_GetAPI");
                    }
                #else
                    if(void *mod = dlopen("librenderdoc.so", RTLD_NOW | RTLD_NOLOAD)) {
                        pRENDERDOC_GetAPI RENDERDOC_GetAPI = (pRENDERDOC_GetAPI)dlsym(mod, "RENDERDOC_GetAPI");
                    }
                #endif

                int ret = RENDERDOC_GetAPI(eRENDERDOC_API_Version_1_0_0, (void**)&api);
            }
        ]]}))
    end)
