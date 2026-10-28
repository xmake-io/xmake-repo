function add_urls(scheme, arch)
    if arch == "x86_64" then
        scheme:add("urls", "https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/LLVM-$(version)-Linux-X64.tar.xz", {alias = "archive"})
        scheme:add("urls", "https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-x86_64-linux-gnu-ubuntu-18.04.tar.xz", {alias = "legacy"})
        scheme:add("versions", "archive:23.1.4", "25d814fda50d5fb0084b42be09605d8b1595d49d5e2e03a3345d7e112ff6f9f3")
        scheme:add("versions", "archive:22.1.8", "df0e1ecf16caf3489a272a5eea4eec9b0d82878f6477fa309504f918a0006384")
        scheme:add("versions", "archive:21.1.8", "b3b7f2801d15d50736acea3c73982994d025b01c2f035b91ae3b49d1b575732b")
        scheme:add("versions", "archive:20.1.8", "1ead36b3dfcb774b57be530df42bec70ab2d239fbce9889447c7a29a4ddc1ae6")
        scheme:add("versions", "archive:19.1.7", "4a5ec53951a584ed36f80240f6fbf8fdd46b4cf6c7ee87cc2d5018dc37caf679")
        scheme:add("versions", "legacy:18.1.8", "54ec30358afcc9fb8aa74307db3046f5187f9fb89fb37064cdde906e062ebf36")
    elseif arch == "arm64" then
        scheme:add("urls", "https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/LLVM-$(version)-Linux-ARM64.tar.xz", {alias = "archive"})
        scheme:add("urls", "https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-aarch64-linux-gnu.tar.xz", {alias = "legacy"})
        scheme:add("versions", "archive:23.1.4", "9b27cf263d711aa6ebfd4045ab241d947bd09b3cd19ffa5728f48a80c9eb3a91")
        scheme:add("versions", "archive:22.1.8", "805efad2bb91cb4967fa569e0881d10c0f69c04461cf671cccbae19f547acc34")
        scheme:add("versions", "archive:21.1.8", "65ce0b329514e5643407db2d02a5bd34bf33d159055dafa82825c8385bd01993")
        scheme:add("versions", "archive:20.1.8", "b855cc17d935fdd83da82206b7a7cfc680095efd1e9e8182c4a05e761958bef8")
        scheme:add("versions", "legacy:19.1.7", "a73d9326e5d756e3937df6a9f621664d76403b59119f741901106b387e53a6ae")
        scheme:add("versions", "legacy:18.1.8", "dcaa1bebbfbb86953fdfbdc7f938800229f75ad26c5c9375ef242edad737d999")
    end
end
