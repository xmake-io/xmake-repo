import("lib.detect.find_tool")
import("core.project.target")

function main(package, opt)
    if opt.system then
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
            version = version:trim()
        end
        if package:is_toolchain() then
            if version then
                return {version = version}
            end
        else
            local linkdir = try {function() return os.iorunv(llvm_config, {"--libdir"}) end}
            local includedir = try {function() return os.iorunv(llvm_config, {"--includedir"}) end}
            if linkdir and includedir then
                linkdir = linkdir:trim()
                includedir = includedir:trim()
                local result = {version = version, links = {}, linkdirs = linkdir, includedirs = includedir}
                local components = {}
                for _, file in ipairs(os.files(path.join(os.scriptdir(), "components", "*.lua"))) do
                    local name = path.basename(file)
                    local links = {}
                    for _, link in ipairs(import("components." .. name).get_links(package)) do
                        local filename_static = target.filename(link, "static", {plat = package:plat(), arch = package:arch()})
                        local filename_shared = target.filename(link, "shared", {plat = package:plat(), arch = package:arch()})
                        if os.isfile(path.join(linkdir, filename_static)) or
                            os.isfile(path.join(linkdir, filename_shared)) then
                            table.insert(links, link)
                            table.insert(result.links, link)
                        end
                    end
                    if #links > 0 then
                        components[name] = components[name] or {}
                        components[name].links = links
                    end
                end
                components.__base = {linkdirs = linkdir, includedirs = includedir}
                result.components = components
                return result
            end
        end
    end
end

