add_rules("mode.debug", "mode.release")

option("pseudo_double_exp_bits", {default = "16", showmenu = true, description = "This sets the number of bits in the exponent, defaulting to 16 if not set."})
option("pd_error_check", {default = true, showmenu = true, description = "This enables error checking in the library, defaulting to true if not set."})

add_requires("pseudo-double-c", {configs = {shared = get_config("shared"), pseudo_double_exp_bits = get_config("pseudo_double_exp_bits"), pd_error_check = get_config("pd_error_check")}})

target("pseudo-double-cpp")
    set_kind("$(kind)")
    set_languages("c++11")
    add_packages("pseudo-double-c")

    if is_plat("windows") then
        add_defines("_MSC_VER")
    end

    add_files("pseudo_double.cpp")
    add_headerfiles("(PseudoDouble.h)")