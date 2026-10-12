function main(package)
    local installdir = package:installdir():gsub("\\", "/")
    local openssldir = (package:config("openssldir") or package:installdir("ssl")):gsub("\\", "/")
    if package:is_plat("mingw", "msys") and is_subhost("msys") then
        installdir = installdir:gsub("(%a):/(.+)", "/%1/%2")
        openssldir = openssldir:gsub("(%a):/(.+)", "/%1/%2")
    end
    local configs = {
        package:config("shared") and "shared" or "no-shared",
        package:is_debug() and "--debug" or "--release",
        package:config("fips") and "enable-fips" or "no-fips",
        package:config("multi-threading") and "threads" or "no-threads",
        "--prefix=" .. installdir,
        "--openssldir=" .. openssldir,
        "--libdir=lib",
        "no-docs", "no-tests", "no-unit-test"
    }
    if package:config("md2") then
        table.insert(configs, "enable-md2")
    end
    if package:is_plat("windows") then
        if package:has_runtime("MT", "MTd") then
            table.insert(configs, "enable-static-vcruntime")
        end
    elseif not package:is_plat("mingw", "msys") then
        table.insert(configs, (package:config("shared") or package:config("pic") ~= false) and "-fPIC" or "no-pic")
    end
    for _, opt in ipairs((package:config("extra_build_opts") or ""):split(",", {plain = true})) do
        opt = opt:trim()
        if #opt > 0 then
            table.insert(configs, opt)
        end
    end
    return configs
end
