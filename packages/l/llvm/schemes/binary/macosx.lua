function add_urls(scheme, arch)
    if arch == "arm64" then
        scheme:add("urls", "https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/LLVM-$(version)-macOS-ARM64.tar.xz", {alias = "archive"})
        scheme:add("urls", "https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/clang+llvm-$(version)-arm64-apple-macos11.tar.xz", {alias = "legacy"})
        scheme:add("versions", "archive:23.1.4", "5d3179db39adeca5b17a34d82708fe976bc60e055b05fe557878fb3fb64d39ef")
        scheme:add("versions", "archive:22.1.8", "f260f4f7c0d430828a81ae8a3826a1d63fc0963ec2459489308cc23b1f7eab4f")
        scheme:add("versions", "archive:21.1.8", "b95bdd32a33a81ee4d40363aaeb26728a26783fcef26a4d80f65457433ea4669")
        scheme:add("versions", "archive:20.1.8", "a9a22f450d35f1f73cd61ab6a17c6f27d8f6051d56197395c1eb397f0c9bbec4")
        scheme:add("versions", "archive:19.1.7", "d93bf12952d89fe4ec7501c40475718b722407da6a8d651f05c995863468e570")
        scheme:add("versions", "legacy:18.1.8", "4573b7f25f46d2a9c8882993f091c52f416c83271db6f5b213c93f0bd0346a10")
    end
end
