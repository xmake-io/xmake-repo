set_project("libass")
add_requires("freetype", "fribidi", "harfbuzz")

includes("check_cfuncs.lua")
add_rules("mode.debug", "mode.release")
if is_plat("windows") and is_kind("shared") then
     add_rules("utils.symbols.export_all")
end

option("asm")
    set_default(true)
    set_description("compiling with ASM")
    add_defines("CONFIG_ASM")
option("large-tiles")
    set_default(false)
    set_description("use larger tiles in the rasterizer (better performance, slightly worse quality)")
    add_defines("CONFIG_LARGE_TILES")
option("system-font-provider")
    on_check(function (option)
        option:enable(not is_plat("wasm"))
    end)
    set_description("enable checking for system fonts provider")

target("ass")
    set_kind("$(kind)")
    add_options("asm", "large-tiles", "system-font-provider")
    add_packages("freetype", "fribidi", "harfbuzz")
    add_files("libass/*.c|ass_fontconfig.c|ass_directwrite.c|ass_coretext.c",
              "libass/c/*.c")
    add_includedirs("libass", "libass/c", "$(buildir)")
    add_syslinks("m")
    add_configfiles("config.h.in")
    configvar_check_cfuncs("HAVE_STRDUP", "strdup", {includes = "string.h"})
    configvar_check_cfuncs("HAVE_STRNDUP", "strndup", {includes = "string.h"})
    if has_config("asm") then
        if is_arch("x64", "x86", "x86_64") then
            set_toolset("as", "nasm")
            add_files("libass/x86/*.asm|utils.asm|x86inc.asm")
            add_includedirs("libass/x86")
            add_defines("ARCH_X86=1", "private_prefix=ass")
            if is_arch("x86") then
                add_defines("ARCH_X86_64=0", "BITMODE=32")
            else
                add_defines("ARCH_X86_64=1", "BITMODE=64")
            end
            if is_plat("windows") and is_arch("x86") then
               add_defines("PREFIX")
            elseif is_plat("macosx") then
                add_defines("PREFIX", "STACK_ALIGNMENT=16")
            elseif is_plat("linux") then
                add_defines("STACK_ALIGNMENT=16")
            end
        elseif is_arch("arm64.*", "aarch64") then
            add_files("libass/aarch64/*.S")
            add_defines("ARCH_AARCH64")
        end
    end
    if has_config("system-font-provider") then
        on_config(function (target)
            -- directwrite
            if target:is_plat("windows") and target:has_cincludes("dwrite_c.h") then
                if target:check_csnippets([[#include <winapifamily.h>
                #if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP)
                #error Win32 desktop APIs are available
                #endif]]) then
                    target:add("syslinks", "dwrite")
                else
                    target:add("syslinks", "gdi")
                end
                target:add("files", "libass/ass_directwrite.c")
                target:add("defines", "CONFIG_DIRECTWRITE")
            end
            -- coretext
            if target:is_plat("macosx") then
                if target:has_cfuncs("CTFontDescriptorCopyAttribute", {includes = "ApplicationServices/ApplicationServices.h"}) then
                    target:add("frameworks", "ApplicationServices", "CoreFoundation")
                    target:add("files", "libass/ass_coretext.c")
                    target:add("defines", "CONFIG_CORETEXT=1")
                elseif target:has_cincludes("CoreText/CoreText.h") then
                    target:add("frameworks", "CoreText", "CoreFoundation")
                    target:add("files", "libass/ass_coretext.c")
                    target:add("defines", "CONFIG_CORETEXT=1")
                end
            end
            -- fontconfig
            if target:has_cincludes("fontconfig/fontconfig.h") then
                target:add("files", "libass/ass_fontconfig.c")
                target:add("defines", "CONFIG_FONTCONFIG")
                target:add("syslinks", "fontconfig")
            end
        end)
    end
    add_headerfiles("libass/ass.h", "libass/ass_types.h", {prefix = "include/libass"})
