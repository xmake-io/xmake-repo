package("gtest")

    set_homepage("https://github.com/google/googletest")
    set_description("Google Testing and Mocking Framework.")

    add_urls("https://github.com/google/googletest/archive/release-$(version).zip", {alias = "archive"})
    add_urls("https://github.com/google/googletest.git", {alias = "github"})
    add_versions("github:1.8.1", "release-1.8.1")
    add_versions("archive:1.8.1", "927827c183d01734cc5cfef85e0ff3f5a92ffe6188e0d18e909c5efebf28a0c7")

    on_install(function (package)
        os.cp("./googletest/include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            int factorial(int number) { return number <= 1 ? number : factorial(number - 1) * number; }
            TEST(FactorialTest, Zero) {
              EXPECT_EQ(1, factorial(1));
              EXPECT_EQ(2, factorial(2));
              EXPECT_EQ(6, factorial(3));
              EXPECT_EQ(3628800, factorial(10));
            }
        ]]}, {configs = {languages = "c++11"}, includes = "gtest/gtest.h"}))
    end)
