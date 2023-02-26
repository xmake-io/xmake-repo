package("ruy")
    set_homepage("https://github.com/google/ruy")
    set_description("Matrix multiplication library")
    set_license("Apache-2.0")
    
    set_urls("https://github.com/google/ruy.git")
    add_versions("2022.09.16", "3168a5c8f4c447fd8cea94078121ee2e2cd87df0")

    add_deps("cmake", "cpuinfo")

    on_install("windows", "linux", "macosx", "android", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        table.insert(configs, "-DRUY_FIND_CPUINFO=ON")

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
         assert(package:check_cxxsnippets({test = [[
            #include <iostream>
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

                std::cout << "Example Mul, float:\n";
                std::cout << "LHS:\n" << lhs;
                std::cout << "RHS:\n" << rhs;
                std::cout << "Result:\n" << dst << "\n";
            }
        ]]}, {configs = {languages = "c++14"}, includes = "ruy/ruy.h"}))
    end)
