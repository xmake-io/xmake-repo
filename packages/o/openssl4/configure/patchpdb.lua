function _patch_msvc_release_pdb(package)
    if package:is_plat("windows") then
        io.replace("Configurations/10-main.conf", "/debug", "", {plain = true})
        io.replace("Configurations/10-main.conf", "/Zi", "", {plain = true})
        io.replace("Configurations/50-masm.conf", "/Zi", "", {plain = true})
        io.replace("Configurations/50-win-clang-cl.conf", "/Zi", "", {plain = true})
        io.replace("util/copy.pl", "if (-d $dest)", "if (! -e $_) { next; }\n\tif (-d $dest)", {plain = true})
    end
end


function main(package)
    _patch_msvc_release_pdb(package)
end
