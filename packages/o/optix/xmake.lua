package("optix")

    set_homepage("https://developer.nvidia.com/optix")
    set_description("NVIDIA OPTIX™ RAY TRACING ENGINE")

    on_fetch(function (package, opt)
        if opt.system then
            import("lib.detect.find_path")
            import("core.base.semver")

            local paths = {"$(env OptiX_ROOT)"}
            if package:is_plat("windows") then
                for _, dir in ipairs(os.dirs("$(env PROGRAMDATA)/NVIDIA Corporation/OptiX SDK *.*.*")) do
                    if package:version_str() == "latest" or semver.satisfies(dir:match("OptiX SDK (%d+%.%d+%.%d+)"), package:version_str()) then
                        table.insert(paths, dir)
                    end
                end
            end

            local inc = find_path("optix.h", paths, {suffixes = "include"})
            if inc then
                local result = {includedirs = {inc}}
                local content = io.readfile(path.join(inc, "optix.h"))
                local version_str = content:match("OPTIX_VERSION (%d+)\n")
                if version_str then
                    local version_num = tonumber(version_str)
                    local version = format("%s.%s.%s", math.floor(version_num/10000), math.floor(version_num%10000/100), version_num%100)
                    result.version = version
                end

                return result
            end
        end
    end)
