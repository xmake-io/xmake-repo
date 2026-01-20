function _fix_overlong_make_recipe(package)
    -- Skip when OpenSSL version <= 1.1.0 as they don't have the `Configurations` directory
    -- see: https://github.com/xmake-io/xmake-repo/issues/8282
    if package:version():le("1.1.0") then
        return
    end
    -- In the MSYS environment, the make recipe can be too long to execute.
    -- This patch is adapted from OpenSSL 3.
    -- For more details, see: https://github.com/openssl/openssl/issues/12116
    io.gsub("Configurations/00-base-templates.conf", -- replace default AR

            "DEFAULTS%s-=>%s-{" ..
               "(.-)"..
                [[AR%s-=>%s-"%S-"%s-,]].. 	-- AR		=> "ar",
            "(.-)}",

            "DEFAULTS => {"..
                "%1"..
                [[AR => "(unused)",]] ..
            "%2}")
    io.gsub("Configurations/00-base-templates.conf", -- replace default ARFLAGS

            "DEFAULTS%s-=>%s-{" ..
               "(.-)"..
                [[ARFLAGS%s-=>%s-"%S-"%s-,]].. --	ARFLAGS		=> "r",
            "(.-)}",

            "DEFAULTS => {"..
                "%1"..
                [[ARFLAGS => "(unused)",]] ..
            "%2}")
    io.gsub("Configurations/00-base-templates.conf", -- replace BASE_unix ARFLAGS

            "BASE_unix%s-=>%s-{" ..
               "(.-)"..
                [[ARFLAGS%s-=>%s-"%S-"%s-,]].. -- ARFLAGS         => "r",
            "(.-)}",

            "BASE_unix => {"..
                "%1"..
                [[ARFLAGS => "qc",]] ..
            "%2}")
    io.gsub("Configurations/unix-Makefile.tmpl", -- insert fill_lines function

            "(sub%s-dependmagic%s-{)" ..
               "(.-)"..
            "}%s-'';",

            "%1"..
                "%2"..
            "}\n"..
            [[
            sub fill_lines {
                my $item_sep = shift;                  # string
                my $line_length = shift;               # number of chars

                my @result = ();
                my $resultpos = 0;

                foreach (@_) {
                    my $fill_line = $result[$resultpos] // '';
                    my $newline =
                        ($fill_line eq '' ? '' : $fill_line . $item_sep) . $_;

                    if (length($newline) > $line_length) {
                        # If this is a single item and the intended result line
                        # is empty, we put it there anyway
                        if ($fill_line eq '') {
                            $result[$resultpos++] = $newline;
                        } else {
                            $result[++$resultpos] = $_;
                        }
                    } else {
                        $result[$resultpos] = $newline;
                    }
                }
                return @result;
            }
            ]]..
            [['';]])

    io.gsub("Configurations/unix-Makefile.tmpl", -- change the way we handle dependencies

            "sub%s-libobj2shlib%s-{" ..
               "(.-)"..
                [[my%s-%$objs.-;]].. -- my $objs = join(" ", @objs);
            "(.-)}",

            "sub libobj2shlib {"..
                "%1"..
                [[my $objs =
                    join(" \\\n\t\t", fill_lines(' ', $COLUMNS - 16, @objs));]] ..
            "%2}")
    io.gsub("Configurations/unix-Makefile.tmpl", -- change the way we handle dependencies

            "sub%s-libobj2shlib%s-{" ..
               "(.-)"..
                [[my%s-%$deps.-;]].. -- my $deps = join(" ", @objs, @defs, @deps);
            "(.-)}",

            "sub libobj2shlib {"..
                "%1"..
                [[my @fulldeps = (@objs, @defs, @deps);
                  my $fulldeps =
                    join(" \\\n" . ' ' x (length($full) + 2),
                        fill_lines(' ', $COLUMNS - length($full) - 2, @fulldeps));]] ..
            "%2}")
    io.gsub("Configurations/unix-Makefile.tmpl",

            "sub%s-libobj2shlib%s-{" ..
               "(.-)"..
                [[%$target:%s-%$deps]].. -- $target: $deps
            "(.-)}",

            "sub libobj2shlib {"..
                "%1"..
                [[$target: $fulldeps]] ..
            "%2}")
    io.gsub("Configurations/unix-Makefile.tmpl",

            "sub%s-obj2lib%s-{" ..
               "(.-)"..
                [[my%s-%$objs.-;]].. -- my $objs = join(" ", @objs);
            "(.-)}",

            "sub obj2lib {"..
                "%1"..
                [[my $deps = join(" \\\n" . ' ' x (length($lib) + 2),
                      fill_lines(' ', $COLUMNS - length($lib) - 2, @objs));
                my $max_per_call = 250;
                my @objs_grouped;
                push @objs_grouped, join(" ", splice @objs, 0, $max_per_call) while @objs;
                my $fill_lib =
                    join("\n\t", (map { "\$(AR) \$(ARFLAGS) $lib$libext $_" } @objs_grouped));]] ..
            "%2}")
    io.gsub("Configurations/unix-Makefile.tmpl",

            "sub%s-obj2lib%s-{" ..
               "(.-)"..
                [[%$lib%$libext:.-]].. -- $lib$libext: $objs
            "EOF",

            "sub obj2lib {"..
                "%1"..
                "$lib$libext: $deps\n" ..
                '\t' .. [[\$(RM) $lib$libext]] ..'\n' ..
                '\t' .. [[$fill_lib]] ..'\n' ..
                '\t' .. [[\$(RANLIB) \$\@ || echo Never mind.]] .. '\n' ..
            "EOF")
end

function _remove_unused_pod_usage(package)
    -- Perl in "Git for Windows" lacks Pod::Usage, which is only used for help messages in the Configure script.
    -- It is not needed for the build and can be safely removed to avoid errors from the missing module.
    if package:version():le("1.1.0") then
        return
    end
    io.replace("Configure", "use Pod::Usage;", "", {plain = true})
    io.replace("Configure", "pod2usage.-;", "")
end

function _replace_NUL_with_null(package)
    -- The Configure script uses "NUL" to redirect output on Windows when checking NASM.
    -- Creating a file named "NUL" can cause issues because "NUL" is a reserved name in Windows.
    if package:version():le("1.1.0") then
        return
    end
    io.replace("Configurations/10-main.conf", "NUL", "null", {plain = true})
end

function main(package)
    _remove_unused_pod_usage(package)
    _replace_NUL_with_null(package)
    _fix_overlong_make_recipe(package)
end
