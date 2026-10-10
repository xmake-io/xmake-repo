package("xclang")
    set_kind("toolchain")
    set_homepage("https://github.com/clice-io/xclang")
    set_description("A relocatable Clang toolchain with bundled Linux and Windows sysroots")
    set_license("Apache-2.0")

    -- Every host archive includes all targets; select the programs by host ABI.
    local archs = {x64 = "x86_64", x86_64 = "x86_64", arm64 = "aarch64", aarch64 = "aarch64"}
    local arch = archs[os.arch()]
    local host
    if is_host("windows") then
        host = "w64-mingw32"
    elseif is_host("linux") then
        host = "unknown-linux-gnu"
    elseif is_host("macosx") then
        host = "apple-darwin"
    end
    local hashes = {
        ["x86_64-w64-mingw32"] = "bc20b77896354af7a2f9aa233565c3a7c1b63eb6512d452c233cf44e40add7fa",
        ["aarch64-w64-mingw32"] = "f84c9a6d16a45e1569a1191f811bfa14b3923b6eba0be7c84a2738e59cb37554",
        ["x86_64-unknown-linux-gnu"] = "a2496b3f4f5ff175928457ec73c8dfea9fa1a7bc4e4f5e2616425c9a863627ec",
        ["aarch64-unknown-linux-gnu"] = "2d573931ddb9319aeabf6c761ab78a33ecf2b03dc8573ff92e5f07b5090e5a61",
        ["x86_64-apple-darwin"] = "592d599973199c4ad7c219a13f14b8ccea2dc26746fce96c97e5474325fd1139",
        ["aarch64-apple-darwin"] = "15d77e05163abe8cf202434c04efa9e770902d5290ba243c152dc1ab962cae86"
    }
    if arch and host then
        local triple = arch .. "-" .. host
        add_urls("https://github.com/clice-io/xclang/releases/download/$(version)/xclang-$(version)-" .. triple .. ".tar.xz",
                 {version = function (version) return version:gsub("%+", ".") end})
        -- Use a semantic version for upstream's four-component release number.
        add_versions("23.1.2+9", hashes[triple])
    end

    on_install("@windows|x64", "@windows|arm64", "@linux|x86_64", "@linux|arm64", "@macosx|x86_64", "@macosx|arm64", function (package)
        os.cp("*", package:installdir(), {symlink = true})
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        local suffix = is_host("windows") and ".exe" or ""
        for _, tool in ipairs({"xclang", "clang++", "llvm-ar"}) do
            local program = package:installdir("bin", tool .. suffix)
            os.vrunv(program, {"--version"})
        end
    end)
