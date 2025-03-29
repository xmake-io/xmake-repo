function main(package)
    io.replace("meson.build", "git = find_program('git', required: false)", "", {plain = true})
    io.replace("meson.build", "if git.found() and is_git_repo", "if false", {plain = true})
    -- Swap from cmake to pkg-config
    io.replace("meson.build",
        [[nanopb = dependency('nanopb', required: get_option('wrap_mode') == 'nofallback', method: 'cmake',]],
        [[nanopb = dependency('nanopb', method: 'pkg-config')]], {plain = true})
    io.replace("meson.build", "modules: ['nanopb::protobuf-nanopb-static'])", "", {plain = true})
    io.replace("meson.build",
        [[libgit2 = dependency('libgit2', required: get_option('wrap_mode') == 'nofallback')]],
        [[libgit2 = dependency('libgit2', required: false)
if not libgit2.found()
libgit2 = dependency('libgit2', method: 'pkg-config')
endif
]], {plain = true})
    if package:is_plat("windows", "mingw") then
        io.replace("src/compat/path.c", "defined (HAVE_GETCWD)", "0", {plain = true})
        io.replace("src/compat/path.c", "defined (HAVE_GETCURRENTDIRECTORY)", "1", {plain = true})
        if not package:config("shared") then
            if package:is_plat("windows") then
                io.replace("include/criterion/internal/common.h", "__declspec(dllimport)", "", {plain = true})
            elseif package:is_plat("mingw") then
                io.replace("include/criterion/internal/common.h", "CR_ATTRIBUTE(dllimport)", [[__attribute__((visibility("default")))]], {plain = true})
            end
        end
        io.replace("src/entry/params.c", "#ifdef HAVE_ISATTY", "#if 0", {plain = true})
        io.replace("src/entry/params.c", "opts[]", "opts[28]", {plain = true})
    else
        io.replace("src/compat/path.c", "defined (HAVE_GETCWD)", "1", {plain = true})
        io.replace("src/compat/path.c", "defined (HAVE_GETCURRENTDIRECTORY)", "0", {plain = true})
    end
end
