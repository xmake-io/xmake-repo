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
function _patch_android(package)
    if package:is_plat("android") and os.isfile("Configurations/15-android.conf") then
        io.replace("Configurations/15-android.conf",
            "$ndk = canonpath($ndk);",
            "$ndk = canonpath($ndk);\n            $ndk =~ s|\\\\|/|g;", {plain = true})
        io.replace("Configurations/15-android.conf",
            'if (which("clang") =~ m|^$ndk/.*/prebuilt/([^/]+)/|) {',
            'my $which_clang = which("clang") // "";\n            $which_clang =~ s|\\\\|/|g;\n            if ($which_clang =~ m|/toolchains/llvm/prebuilt/([^/]+)/|) {', {plain = true})
        io.replace("Configurations/15-android.conf",
            'if (which("llvm-ar") =~ m|^$ndk/.*/prebuilt/([^/]+)/|) {',
            'my $which_ar = which("llvm-ar") // "";\n            $which_ar =~ s|\\\\|/|g;\n            if ($which_ar =~ m|/toolchains/llvm/prebuilt/([^/]+)/| || $which_clang =~ m|/toolchains/llvm/prebuilt/([^/]+)/|) {', {plain = true})
    end
end


function main(package)
    _add_ohos_targets(package)
    _patch_android(package)
end
