function _remove_unused_modules()
    io.replace("Configure", "use Pod::Usage;", "", {plain = true})
    io.replace("Configure", "pod2usage.-;", "")
end

function main(package, opt)
    if not package:is_plat("windows") and not opt.perl.use_unix_path then
        os.tryrm("Configurations/unix*-checker.pm")
    end
    if package:is_plat("windows") and opt.perl.use_unix_path then
        io.replace("Configurations/10-main.conf", "NUL", "null", {plain = true})
    end
    _remove_unused_modules()
end
