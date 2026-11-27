add_rules("mode.debug", "mode.release")

target("bid")
    set_kind("$(kind)")
    add_headerfiles("LIBRARY/src/*.h", {prefixdir = "intelrdfpmathlib"})

    add_defines(
        "BID_BIG_ENDIAN=1",
        "DECIMAL_CALL_BY_REFERENCE=0",
        "DECIMAL_GLOBAL_ROUNDING=0",
        "DECIMAL_GLOBAL_EXCEPTION_FLAGS=0"
    )

    if is_plat("windows", "mingw", "msys") then
        add_defines("WINDOWS")
    elseif is_plat("macosx") then
        add_defines("LINUX=1", "mach=1")
    elseif is_plat("bsd") then
        add_defines("LINUX=1", "freebsd=1")
    else
        add_defines("LINUX=1", "linux=1")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end

    on_config(function (target)
        local native_128 = target:has_tool("cc", "icl")
        if native_128 then
            target:add("files", "LIBRARY/src/*.c", {
                defines = {"USE_COMPILER_F128_TYPE=1", "USE_COMPILER_F80_TYPE=1"},
                cflags = {"/Qlong-double", "/Qpc80", "/Qstd=c99", "-Qoption,cpp,--extended_float_types"},
            })
        else
            target:add("files", "LIBRARY/src/*.c", {
                defines = {"USE_COMPILER_F128_TYPE=0", "USE_COMPILER_F80_TYPE=0"},
            })
        end

        if native_128 then
            return
        end

        -- local defines = {}
        -- local is_64 = (target:check_sizeof("void*") == 8)
        -- if target:is_plat("windows", "mingw", "msys") then
        --     table.insert(defines, (is_64 and "win64" or "winnt"))
        -- end

        -- local float128 = {
        --     "dpml_ux_bid.c",
        --     "dpml_ux_bessel.c",
        --     "dpml_ux_cbrt.c",
        --     "dpml_ux_erf.c",
        --     "dpml_ux_exp.c",
        --     "dpml_ux_int.c",
        --     "dpml_ux_inv_hyper.c",
        --     "dpml_ux_inv_trig.c",
        --     "dpml_ux_lgamma.c",
        --     "dpml_ux_log.c",
        --     "dpml_ux_mod.c",
        --     "dpml_ux_powi.c",
        --     "dpml_ux_pow.c",
        --     "dpml_ux_sqrt.c",
        --     "dpml_ux_trig.c",
        --     "dpml_ux_ops.c",
        --     "dpml_ux_ops_64.c",
        --     "dpml_four_over_pi.c",
        --     "dpml_exception.c",
        --     "sqrt_tab_t.c",
        -- }
        -- for _, file in ipairs(float128) do
        --     target:add("files", path.join("LIBRARY/float128", file), {
        --         defines = table.join({"USE_NATIVE_QUAD_TYPE=0"}, defines)
        --     })
        -- end

        -- if target:has_tool("cc", "cl") then
        --     local float53 = {
        --         "dpml_asinh_t.c", {defines = "ASINH"}
        --         "dpml_acosh_t.c",
        --         "dpml_cbrt_t.c",
        --         "dpml_erf_t.c",
        --         "dpml_erfc_t.c",
        --         "dpml_expm1_t.c",
        --         "dpml_exp10_t.c",
        --         "dpml_exp2_t.c",
        --         "dpml_lgamma_t.c",
        --         "dpml_log1p_t.c",
        --         -- "dpml_log2_t.c",
        --         "dpml_tgamma_t.c",
        --         "dpml_rt_lgamma_t.c", {defines = "T_FLOAT"}
        --         "dpml_pow_t_table.c",
        --         "dpml_cbrt_t_table.c", {defines = {"BUILD_FILE_NAME=dpml_cbrt_t_table.c", "CBRT"}}
        --         "dpml_special_exp_t.c",
        --     }
        --     if target:check_sizeof("void*") == 4 then
        --         table.insert(float53, "dpml_log2_t.c")
        --     end

        --     table.join2(defines, "T_FLOAT")
        --     for file, flags file in pairs(float53) do
        --         table.join2(flags.defines, defines)
        --         target:add("files", path.join("LIBRARY/float128", file), flags)
        --     end
        -- end
    end)
