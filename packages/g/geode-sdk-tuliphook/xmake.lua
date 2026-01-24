package("geode-sdk-tuliphook")
    set_homepage("https://github.com/geode-sdk/TulipHook")
    set_description("Low level hooking lib specialized for Geometry Dash. Supports Windows x86/x86_64, macOS x86_64/aarch64, Android armv7/aarch64, iOS aarch64")
    set_license("BSL-1.0")

    add_urls("https://github.com/geode-sdk/TulipHook/archive/refs/tags/$(version).tar.gz",
             "https://github.com/geode-sdk/TulipHook.git")

    add_versions("v3.1.7", "83f200a43002a343a17f57f861532d64018f8e7691a3c0097356df3dc1743543")

    add_deps("geode-sdk-result")


    if not is_plat("android") then
        add_deps("capstone")
    end

    on_load(function (package)
        if not package:is_plat("windows", "mingw") then
            package:add("links", "tuliphook", "dobby")
        end
    end)

    on_install("!wasm and !cross and !bsd and !iphoneos", function (package)
        io.writefile("xmake.lua", [[
            add_requires("geode-sdk-result")
            add_packages("geode-sdk-result")

            if not is_plat("android") then
                add_requires("capstone")
                add_packages("capstone")
            end

            if not is_plat("windows", "mingw") then
                target("dobby")
                    set_kind("static")
                    set_languages("c++20")

                    add_includedirs(
                        "libraries/dobby/external", 
                        "libraries/dobby/include",
                        "libraries/dobby/source",
                        "libraries/dobby/source/dobby"
                    )

                    add_files(
                        "libraries/dobby/source/core/arch/**.cc",
                        "libraries/dobby/source/core/assembler/**.cc",
                        "libraries/dobby/source/core/codegen/**.cc",
                        "libraries/dobby/source/InstructionRelocation/arm/**.cc",
                        "libraries/dobby/source/MemoryAllocator/**.cc",
                        "libraries/dobby/source/MemoryAllocator/CodeBuffer/**.cc"
                    )

                    add_headerfiles(
                        "libraries/dobby/include/(**.h)"
                    )
                    add_headerfiles(
                        "libraries/dobby/source/InstructionRelocation/(**.h)",
                        {prefixdir = "InstructionRelocation"}
                    )
            end

            target("tuliphook")
                set_kind("$(kind)")
                set_languages("c++20")

                add_includedirs(
                    "include",
                    "include/tulip"
                )

                add_headerfiles("include/tulip/(**.hpp)", {prefixdir = "tulip"})

                add_files(
                    "src/*.cpp",
                    "src/assembler/BaseAssembler.cpp",
                    "src/assembler/X86Assembler.cpp",
                    "src/assembler/X64Assembler.cpp",
                    "src/assembler/ArmV7Assembler.cpp",
                    "src/assembler/ThumbV7Assembler.cpp",
                    "src/assembler/ArmV8Assembler.cpp",
                    "src/disassembler/BaseDisassembler.cpp",
                    "src/disassembler/ArmV8Disassembler.cpp",
                    "src/disassembler/ThumbV7Disassembler.cpp",
                    "src/convention/AAPCSConvention.cpp",
                    "src/convention/AAPCS64Convention.cpp",
                    "src/convention/CallingConvention.cpp",
                    "src/convention/DefaultConvention.cpp",
                    "src/convention/SystemVConvention.cpp",
                    "src/convention/Windows32Convention.cpp",
                    "src/convention/Windows64Convention.cpp",
                    "src/generator/Generator.cpp",
                    "src/target/Target.cpp"
                )

                if is_plat("windows", "mingw") then
                    add_files("src/generator/X86Generator.cpp")
                    if is_arch("i386", "x86") then
                        add_files("src/target/Windows32Target.cpp")
                    elseif is_arch("x64", "x86_64") then
                        add_files("src/generator/X64Generator.cpp", "src/target/Windows64Target.cpp")
                    end
                elseif is_plat("macosx", "iphoneos") then
                    add_files("src/target/DarwinTarget.cpp")
                    if is_arch("i386", "x86") then
                        add_files("src/generator/X86Generator.cpp")
                    elseif is_arch("x64", "x86_64") then
                        add_files("src/generator/X86Generator.cpp", "src/generator/X64Generator.cpp")
                    elseif is_arch("arm.*") then
                        add_files("src/generator/ArmV8Generator.cpp")
                    end
                    if is_plat("macosx") then
                        if is_arch("arm.*") then
                            add_files("src/target/MacosM1Target.cpp")
                        else
                            add_files("src/target/MacosIntelTarget.cpp")
                        end
                    elseif is_plat("iphoneos") then
                        add_files("src/target/iOSTarget.cpp")
                    end
                elseif is_plat("android") then
                    add_files("src/target/PosixTarget.cpp")
                    if is_arch("arm64.*") then
                        add_files("src/generator/ArmV8Generator.cpp", "src/target/PosixArmV8Target.cpp")
                    elseif is_arch("arm.*") then
                        add_files("src/generator/ArmV7Generator.cpp", "src/target/PosixArmV7Target.cpp")
                    end
                elseif is_plat("linux") then
                    add_files("src/target/PosixTarget.cpp")
                    if is_arch("i386", "x86") then
                        add_files("src/generator/X86Generator.cpp")
                    elseif is_arch("x64", "x86_64") then
                        add_files("src/generator/X64Generator.cpp", "src/target/PosixX64Target.cpp", "src/generator/X86Generator.cpp")
                    elseif is_arch("arm64.*") then
                        add_files("src/generator/ArmV8Generator.cpp", "src/target/PosixArmV8Target.cpp")
                    elseif is_arch("arm.*") then
                        add_files("src/generator/ArmV7Generator.cpp", "src/target/PosixArmV7Target.cpp")
                    end
                end

                add_defines("TULIP_HOOK_EXPORTING")

                if is_kind("shared") then
                    add_defines("TULIP_HOOK_DYNAMIC")
                end
                if not is_plat("windows", "mingw") then
                    add_deps("dobby")
                    add_includedirs(
                        "libraries/dobby/source",
                        "libraries/dobby/include",
                        "libraries/dobby/external"
                    )
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tulip/TulipHook.hpp>
            void test() {
                static constexpr uint8_t patch1[] = {
                    0x48, 0x83, 0xEC, 0x68,             // sub     rsp, 68h
                    0x66, 0x0F, 0x7F, 0x04, 0x24,       // movdqa  xmmword ptr [rsp], xmm0
                    0x66, 0x0F, 0x7F, 0x4C, 0x24, 0x30, // movdqa  xmmword ptr [rsp+30h], xmm1
                    0x66, 0x0F, 0x7F, 0x54, 0x24, 0x40, // movdqa  xmmword ptr [rsp+40h], xmm2
                    0x66, 0x0F, 0x7F, 0x5C, 0x24, 0x50, // movdqa  xmmword ptr [rsp+50h], xmm3
                };
                auto res = tulip::hook::writeMemory(nullptr, patch1, sizeof(patch1));
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
