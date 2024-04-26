package("llvm-arm")

    set_kind("toolchain")
    set_homepage("https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm")
    set_description("A project dedicated to building LLVM toolchain for 32-bit Arm embedded targets.")

    if is_host("windows") then
        set_urls("https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases/download/release-$(version)/LLVMEmbeddedToolchainForArm-$(version)-Windows-x86_64.zip")
        add_versions("17.0.1", "0ac5aa29d53227bf71c546f7426dde302ad71f064dcae498c5eec0d99ede6739")
    elseif is_host("linux") then
        if os.arch():find("arm64.*") then
            set_urls("https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases/download/release-$(version)/LLVMEmbeddedToolchainForArm-$(version)-Linux-AArch64.tar.xz")
            add_versions("17.0.1", "becd922bec5d5e5683d824fa91ebabe5e0e286b97e209ebd3398f56f5b9ef4ed")
        else
            set_urls("https://github.com/ARM-software/LLVM-embedded-toolchain-for-Arm/releases/download/release-$(version)/LLVMEmbeddedToolchainForArm-$(version)-Linux-x86_64.tar.xz")
            add_versions("17.0.1", "eb7bff945d3c19589ab596a9829de6f05f86b73f52f80da253232360c99ea68f")
        end

    end

    on_install("@windows", "@linux", function (package)
        os.vcp("*", package:installdir())
    end)

    on_test(function (package)
        local clang = "clang"
        if clang and is_host("windows") then
            clang = clang .. ".exe"
        end
        os.vrunv(clang, {"--version"})
    end)

