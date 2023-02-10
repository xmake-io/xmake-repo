import("lib.detect.find_tool")

function main(package, opt)
    if opt.system then
        if package:is_toolchain() then
            local llvm_config = "llvm-config"
            if package:is_plat("macosx") then
                local llvm = try {function () return os.iorunv("brew", {"--prefix", "llvm"}) end}
                if llvm then
                    local ret = find_tool("llvm-config", {paths = path.join(llvm:trim(), "bin")})
                    if ret then
                        llvm_config = ret.program
                    end
                end
            end
            local version = try {function() return os.iorunv(llvm_config, {"--version"}) end}
            if version then
                return {version = version:trim()}
            end
        end
    end
end

