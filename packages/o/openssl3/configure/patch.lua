function _add_ohos_targets(package)
    if package:is_plat("harmony") then
        io.gsub("Configurations/10-main.conf",
            [=[("linux%-x86_64"%s-=>%s-{.-},)]=],
            [=[%1

    "ohos-aarch64" => {
        inherit_from     => [ "linux-aarch64" ],
        shared_extension => ".so"
    },
    "ohos-arm" => {
        inherit_from     => [ "linux-armv4" ],
        ex_libs          => add("-lclang_rt.builtins"),
        shared_extension => ".so"
    },
    "ohos-x86_64" => {
        inherit_from     => [ "linux-x86_64" ],
        shared_extension => ".so"
    },]=])
    end
end

function main(package)
    _add_ohos_targets(package)
end
