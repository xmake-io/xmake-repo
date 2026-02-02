option("simd", {default = false})

add_rules("mode.release", "mode.debug")

set_languages("c++17")

local dirs = os.dirs("src/zimg/*")

target("zimg")
    set_kind("$(kind)")
    add_includedirs("src/zimg")
    for _, dir in ipairs(dirs) do
        add_files(path.join(dir, "*.cpp"))
    end

    add_headerfiles(
        "src/zimg/api/*.h",
        "src/zimg/api/*.hpp"
    )

    add_defines("ZIMG_GRAPHENGINE_API", "GRAPHENGINE_IMPL_NAMESPACE=zimg")

    if has_config("simd") then
        if is_arch("x86", "x64", "x86_64", "i386") then
            add_defines("ZIMG_X86")

            for _, dir in ipairs(dirs) do
                add_files(path.join(dir, "x86/*.cpp"), {vectorexts = "all"})
            end
        elseif is_arch("arm64", "arm64-v8a") then
            add_defines("ZIMG_ARM")

            for _, dir in ipairs(dirs) do
                add_files(path.join(dir, "arm/*.cpp"), {vectorexts = "all"})
            end
        end
    end
