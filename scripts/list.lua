import("packages")

function main(...)
    for plat, pkgs in pairs(packages()) do
        cprint("${magenta}%s${clear}:", plat)
        for _, pkg in ipairs(pkgs) do
            if pkg.generic then
                cprint("  ${yellow}->${clear} %s", pkg.name)
            else
                cprint("  ${yellow}->${clear} %s (%s)", pkg.name, table.concat(pkg.archs, ", "))
            end
        end
    end
end
