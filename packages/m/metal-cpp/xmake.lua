package("metal-cpp")
    set_kind("library", { headeronly = true })
    set_homepage("https://developer.apple.com/metal/cpp/")
    set_description("Metal-cpp is a low-overhead C++ interface for Metal that helps you add Metal functionality to graphics apps, games, and game engines that are written in C++.")
    set_license("Apache-2.0")

    set_urls("https://developer.apple.com/metal/cpp/files/metal-cpp_$(version).zip",
         {version = function (version)
            local versions = {
                ["12"]   = "macOS12_iOS15",
                ["13"]   = "macOS13_iOS16",      -- 13.0
                ["13.3"] = "macOS13.3_iOS16.4",
                ["14.2"] = "macOS14.2_iOS17.2",
                ["15"]   = "macOS15_iOS18",      -- 15.0
                ["15.2"] = "macOS15.2_iOS18.2",
                ["26"]   = "26",
            }
            return versions[tostring(version)]
        end})

    add_versions("12",   "a4e2d4668951b6f2595618ed8c5dc514fc94fda5487fc722b1c1ff29d7b524f7")
    add_versions("13",   "6f741894229e9c750add1afc3797274fc008c7507e2ae726370c17c34b7c6a68")
    add_versions("13.3", "0afd87ca851465191ae4e3980aa036c7e9e02fe32e7c760ac1a74244aae6023b")
    add_versions("14.2", "d800ddbc3fccabce3a513f975eeafd4057e07a29e905ad5aaef8c1f4e12d9ada")
    add_versions("15",   "0433df1e0ab13c2b0becbd78665071e3fa28381e9714a3fce28a497892b8a184")
    add_versions("15.2", "3437e4abfbd3d45217f34772ef3502f31ba3358e5fb6ac9d0ca952a047bcfe25")
    add_versions("26",   "4df3c078b9aadcb516212e9cb03004cbc5ce9a3e9c068fa3144d021db585a3a4")

    -- todo:Move metal-cpp-extensions to github
    add_resources("*", "LearnMetalCPP", "https://developer.apple.com/metal/LearnMetalCPP.zip", "a709f3c0b532d5b9e3a5db3da3a35f3b783af27eb50f23a711115c02f86a256d")

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

    on_check(function (package)
        assert(package:is_plat("macosx", "iphoneos"), "package(metal-cpp) only support macosx or iOS")
    end)

    on_install("macosx", "iphoneos", function (package)
        -- Copy metal-cpp
        if not os.trycp("metal-cpp", package:installdir("include")) then
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
                MTL::Device* pDevice = MTL::CreateSystemDefaultDevice();
                MTL::CommandQueue* pCommnadQueue = pDevice->newCommandQueue();

                CGRect frame = (CGRect){ {100.0, 100.0}, {512.0, 512.0} };
                MTK::View* _pMtkView = MTK::View::alloc()->init( frame, pDevice );
                _pMtkView->setColorPixelFormat( MTL::PixelFormat::PixelFormatBGRA8Unorm_sRGB );
                _pMtkView->setClearColor( MTL::ClearColor::Make( 1.0, 0.0, 0.0, 1.0 ) );
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)