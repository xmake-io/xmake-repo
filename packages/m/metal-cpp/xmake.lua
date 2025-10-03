package("metal-cpp")
    set_kind("library", { headeronly = true })

    add_urls("https://developer.apple.com/metal/cpp/files/metal-cpp_$(version).zip", { 
        version = function (version) 
            if version == "latest" then 
                return "macOS26_iOS26-beta2"
            else
                return version
            end
        end
    })

    add_versions("macOS12_iOS15", "a4e2d4668951b6f2595618ed8c5dc514fc94fda5487fc722b1c1ff29d7b524f7")
    add_versions("macOS13_iOS16", "6f741894229e9c750add1afc3797274fc008c7507e2ae726370c17c34b7c6a68")
    add_versions("macOS13.3_iOS16.4", "0afd87ca851465191ae4e3980aa036c7e9e02fe32e7c760ac1a74244aae6023b")
    add_versions("macOS14_iOS17-beta", "2009a339ecbd56b36601435fe08c415749f8ad09145755472bb637b319003367")
    add_versions("macOS14.2_iOS17.2", "d800ddbc3fccabce3a513f975eeafd4057e07a29e905ad5aaef8c1f4e12d9ada")
    add_versions("macOS15_iOS18-beta", "d0a7990f43c7ce666036b5649283c9965df2f19a4a41570af0617bbe93b4a6e5")
    add_versions("macOS15_iOS18", "0433df1e0ab13c2b0becbd78665071e3fa28381e9714a3fce28a497892b8a184")
    add_versions("macOS15.2_iOS18.2", "3437e4abfbd3d45217f34772ef3502f31ba3358e5fb6ac9d0ca952a047bcfe25")
    add_versions("macOS26_iOS26-beta", "3778084a9b50be7f3dd3edfb127b77b2dcef75c4c71dc23583abb4f8df8bf62d")
    add_versions("macOS26_iOS26-beta2", "4f0e62aac6a875616d8e86a1cb206158312e52b34de72716773b3785eeb12dc6")
    add_versions("latest", "4f0e62aac6a875616d8e86a1cb206158312e52b34de72716773b3785eeb12dc6")

    add_resources("macOS12_iOS15", "LearnMetalCPP", "https://developer.apple.com/metal/LearnMetalCPP.zip", "a709f3c0b532d5b9e3a5db3da3a35f3b783af27eb50f23a711115c02f86a256d")
    add_resources("macOS13_iOS16", "LearnMetalCPP", "https://developer.apple.com/metal/LearnMetalCPP.zip", "a709f3c0b532d5b9e3a5db3da3a35f3b783af27eb50f23a711115c02f86a256d")
    add_resources("macOS13.3_iOS16.4", "LearnMetalCPP", "https://developer.apple.com/metal/LearnMetalCPP.zip", "a709f3c0b532d5b9e3a5db3da3a35f3b783af27eb50f23a711115c02f86a256d")
    add_resources("macOS14_iOS17-beta", "LearnMetalCPP", "https://developer.apple.com/metal/LearnMetalCPP.zip", "a709f3c0b532d5b9e3a5db3da3a35f3b783af27eb50f23a711115c02f86a256d")
    add_resources("macOS14.2_iOS17.2", "LearnMetalCPP", "https://developer.apple.com/metal/LearnMetalCPP.zip", "a709f3c0b532d5b9e3a5db3da3a35f3b783af27eb50f23a711115c02f86a256d")
    add_resources("macOS15_iOS18-beta", "LearnMetalCPP", "https://developer.apple.com/metal/LearnMetalCPP.zip", "a709f3c0b532d5b9e3a5db3da3a35f3b783af27eb50f23a711115c02f86a256d")
    add_resources("macOS15_iOS18", "LearnMetalCPP", "https://developer.apple.com/metal/LearnMetalCPP.zip", "a709f3c0b532d5b9e3a5db3da3a35f3b783af27eb50f23a711115c02f86a256d")
    add_resources("macOS15.2_iOS18.2", "LearnMetalCPP", "https://developer.apple.com/metal/LearnMetalCPP.zip", "a709f3c0b532d5b9e3a5db3da3a35f3b783af27eb50f23a711115c02f86a256d")
    add_resources("macOS26_iOS26-beta", "LearnMetalCPP", "https://developer.apple.com/metal/LearnMetalCPP.zip", "a709f3c0b532d5b9e3a5db3da3a35f3b783af27eb50f23a711115c02f86a256d")
    add_resources("macOS26_iOS26-beta2", "LearnMetalCPP", "https://developer.apple.com/metal/LearnMetalCPP.zip", "a709f3c0b532d5b9e3a5db3da3a35f3b783af27eb50f23a711115c02f86a256d")
    add_resources("latest", "LearnMetalCPP", "https://developer.apple.com/metal/LearnMetalCPP.zip", "a709f3c0b532d5b9e3a5db3da3a35f3b783af27eb50f23a711115c02f86a256d")

    add_includedirs(
        "include", 
        "include/metal-cpp", 
        "include/metal-cpp-extensions"
    )

    add_frameworks("Foundation", "Metal", "MetalKit")

    add_defines(
        "NS_PRIVATE_IMPLEMENTATION",
        "CA_PRIVATE_IMPLEMENTATION",
        "MTL_PRIVATE_IMPLEMENTATION",
        "MTK_PRIVATE_IMPLEMENTATION"
    )

    on_install("macosx", "iphoneos", function (package)
        -- Copy metal-cpp
        print(os.curdir())
        if not os.trycp("metal-cpp", package:installdir("include")) then
            -- print("metal-cpp not found")
            os.vcp("*", package:installdir("include", "metal-cpp"))
        end

        -- Copy metal-cpp-extensions
        local resDir = package:resourcedir("LearnMetalCPP")
        local extDir = path.join(resDir, "/LearnMetalCPP/metal-cpp-extensions")
        os.vcp(extDir, package:installdir("include"))
    end)

    on_test("macosx", "iphoneos", function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <metal-cpp/Foundation/Foundation.hpp>
            #include <metal-cpp/Metal/Metal.hpp>
            #include <Foundation/Foundation.hpp>
            #include <Metal/Metal.hpp>

            #include <MetalKit/MetalKit.hpp>
            #include <AppKit/AppKit.hpp>

            void test () {

            }
        ]]}, {configs = {languages = "c++17"}}))
    end)