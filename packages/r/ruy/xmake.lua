package("ruy")
    set_homepage("https://github.com/google/ruy")
    set_description("Matrix multiplication library")
    set_license("Apache-2.0")
    
    set_urls("https://github.com/google/ruy.git")
    add_versions("2022.09.16", "3168a5c8f4c447fd8cea94078121ee2e2cd87df0")

    add_deps("cpuinfo")

    add_configs("profiler", { description = "Enable ruy's built-in profiler (harms performance)", default = false, type = "boolean" })
    if is_plat("windows") then
        add_configs("shared",     {description = "Build shared library.", default = false, type = "boolean", readonly = true})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MT", readonly = true})
    end

    on_install("windows", "linux", "macosx", "android", function (package)
        os.cp(path.join(os.scriptdir(), "port", "xmake.lua"), "xmake.lua")
        os.rm("BUILD")
        local configs = {}
        configs.profiler = package:config("profiler")
         
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
         assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                ruy::Context context;
                const float lhs_data[] = {1, 2, 3, 4};
                const float rhs_data[] = {1, 2, 3, 4};
                float dst_data[4];

                ruy::Matrix<float> lhs;
                ruy::MakeSimpleLayout(2, 2, ruy::Order::kRowMajor, lhs.mutable_layout());
                lhs.set_data(lhs_data);
                ruy::Matrix<float> rhs;
                ruy::MakeSimpleLayout(2, 2, ruy::Order::kColMajor, rhs.mutable_layout());
                rhs.set_data(rhs_data);
                ruy::Matrix<float> dst;
                ruy::MakeSimpleLayout(2, 2, ruy::Order::kColMajor, dst.mutable_layout());
                dst.set_data(dst_data);

                ruy::MulParams<float, float> mul_params;
                ruy::Mul(lhs, rhs, mul_params, &context, &dst);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "ruy/ruy.h"}))
    end)