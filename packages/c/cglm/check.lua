import("core.base.semver")

function main(argv)
    local vs_sdkver = argv.vs_sdkver
    if vs_sdkver then
        vs_sdkver = semver.new(vs_sdkver)
        if vs_sdkver:le("10.0.17763") then
            wprint(format("vs_sdkver <= 10.0.17763.0, skip package(%s) test", path.basename(os.scriptdir())))
            return false
        end
    end

    return true
end
