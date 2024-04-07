package("aitoolkit")
    set_kind("library", {headeronly = true})
    set_homepage("https://linkdd.github.io/aitoolkit/")
    set_description("Give a brain to your game's NPCs")
    set_license("MIT")

    add_urls("https://github.com/linkdd/aitoolkit/archive/refs/tags/$(version).tar.gz",
             "https://github.com/linkdd/aitoolkit.git")

    add_versions("v0.5.0", "e2f59412a6cdc7389f25f4b85847e81c39866d33367515bd02e38be4d54ac74c")
    add_versions("v0.3.0", "8cbe1d281235a3486c5840c7f9782f2b3b2ed181d76e8cbe83a2b1395d21ab8a")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <aitoolkit/fsm.hpp>
            using namespace aitoolkit::fsm;

            struct blackboard_type{};
            class state_dummy final : public state<blackboard_type> {
            public:
                virtual void enter(blackboard_type& blackboard) override {}
            };
            void test() {
                auto simple_bb = blackboard_type{};
                auto simple_fsm = simple_machine<blackboard_type>();
                simple_fsm.set_state(std::make_shared<state_dummy>(), simple_bb);
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
