option("simd", {default = false})

add_rules("mode.release", "mode.debug")

set_languages("c++17")

target("zimg")
    set_kind("$(kind)")
    add_includedirs("src/zimg")
    add_files("src/zimg/*/*.cpp")
    add_headerfiles(
        "src/zimg/api/*.h",
        "src/zimg/api/*.hpp"
    )

    add_defines("ZIMG_GRAPHENGINE_API", "GRAPHENGINE_IMPL_NAMESPACE=zimg")

    if has_config("simd") then
        if is_arch("x86", "x64", "x86_64", "i386") then
            add_defines("ZIMG_X86")
            add_files("src/zimg/*/x86/*.cpp", {vectorexts = "all"})
        elseif is_arch("arm64", "arm64-v8a") then
            add_defines("ZIMG_ARM")
            add_files("src/zimg/*/arm/*.cpp", {vectorexts = "all"})
        end
    end
