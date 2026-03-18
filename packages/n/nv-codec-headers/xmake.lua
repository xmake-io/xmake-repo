package("nv-codec-headers")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/FFmpeg/nv-codec-headers")
    set_description("FFmpeg headers for NVIDIA codec APIs (NVENC/NVDEC)")

    add_urls("https://github.com/FFmpeg/nv-codec-headers/releases/download/n$(version)/nv-codec-headers-$(version).tar.gz", {alias = "github"})
    add_urls("https://github.com/FFmpeg/nv-codec-headers.git", {alias = "git"})

    add_versions("github:13.0.19.0", "13da39edb3a40ed9713ae390ca89faa2f1202c9dda869ef306a8d4383e242bee")
    add_versions("git:13.0.19.0", "n13.0.19.0")

    on_install(function (package)
        os.cp("include/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <ffnvcodec/nvEncodeAPI.h>
            int main(void) {
                NV_ENCODE_API_FUNCTION_LIST api = {0};
                api.version = NV_ENCODE_API_FUNCTION_LIST_VER;
                return (int)api.version;
            }
        ]]}))
    end)
