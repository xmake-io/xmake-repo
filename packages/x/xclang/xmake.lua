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
        ["x86_64-w64-mingw32"] = "7ba24a2bff6275117e7b3f214850b3726f7cac2c5066d49e2b04f8aaa5685c24",
        ["aarch64-w64-mingw32"] = "2c2f198108ce60283ce722643d7d125b2e249491a9a3603952b9996f1d4574e2",
        ["x86_64-unknown-linux-gnu"] = "ea6394410c102a3cbd2d0afc2d59935404c0a51298bc944ebd25490e6cc0d568",
        ["aarch64-unknown-linux-gnu"] = "84c7e20a242f2a40a8d377a668c836337b808ebc0d1e73e165e288183a329821",
        ["x86_64-apple-darwin"] = "484028870d18cb904c348e2610cb41e3b765950c0bd4a9c9690ec93e729e92b4",
        ["aarch64-apple-darwin"] = "b3c2c8022885473ab838e31019c0a7b07cff78d723ca1e28dcbd7e40d0f55caa"
    }
    if arch and host then
        local triple = arch .. "-" .. host
        add_urls("https://github.com/clice-io/xclang/releases/download/$(version)/xclang-$(version)-" .. triple .. ".tar.xz",
                 {version = function (version) return version:gsub("%+", ".") end})
        -- Use a semantic version for upstream's four-component release number.
        add_versions("23.1.2+10", hashes[triple])
    end

    on_install("@windows|x64", "@windows|arm64", "@linux|x86_64", "@linux|arm64", "@macosx|x86_64", "@macosx|arm64", function (package)
        os.cp("*", package:installdir(), {symlink = true})
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        for _, tool in ipairs({"xclang", "clang++", "llvm-ar"}) do
            os.vrunv(tool, {"--version"})
        end
    end)
