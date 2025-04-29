package("witty")
    set_homepage("http://www.webtoolkit.eu/wt")
    set_description("Wt, C++ Web Toolkit")
    set_license("GPL-2.0")

    add_urls("https://github.com/emweb/wt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/emweb/wt.git")

    add_versions("4.11.4", "b42b9818e4c8ab8af835b0c88bda5c4f71ccfb38fd8baf90648064b0544eb564")

    add_deps("cmake")
    add_deps("boost", {
        configs = {
            algorithm = true, array = true, asio = true,
            bind = true, config = true, container_hash = true,
            filesystem = true, foreach = true, fusion = true,
            interprocess = true, lexical_cast = true, logic = true,
            math = true, multi_index = true, optional = true,
            phoenix = true, pool = true, program_options = true,
            range = true, serialization = true, smart_ptr = true,
            spirit = true, system = true, thread = true,
            tokenizer = true, tuple = true, ublas = true, variant = true,
            shared = true
        } -- include\boost\filesystem\config.hpp(96,1): error C1189: #error:  Must not define both BOOST_FILESYSTEM_DYN_LINK and BOOST_FILESYSTEM_STATIC_LINK
    })
    add_deps("glew", "libharu", "libpng", "openssl", "zlib")
    if not is_plat("windows") then
        add_deps("harfbuzz", "pango")
    end

    if is_plat("windows") then
        add_syslinks("d2d1", "dwrite", "windowscodecs", "shlwapi")
    end

    on_install("!wasm and !mingw and !iphoneos and !android and !cross", function (package)

        local zlib = package:dep("zlib")
        local zlib_prefix = "";
        if zlib and not zlib:is_system() then
            zlib_prefix = zlib:installdir()
        end

        local configs = {
            "-DBUILD_EXAMPLES=OFF", "-DBUILD_TESTS=OFF", "-DCONNECTOR_HTTP=ON", "-DENABLE_HARU=ON",
            "-DENABLE_MYSQL=OFF", "-DENABLE_FIREBIRD=OFF", "-DENABLE_QT4=OFF", "-DENABLE_QT5=OFF",
            "-DENABLE_LIBWTTEST=ON", "-DENABLE_OPENGL=ON", "-DCMAKE_INSTALL_DIR=share"
        }
        table.insert(configs, "-DZLIB_PREFIX=" .. zlib_prefix)
        table.insert(configs, "-DLIBPNG_PREFIX=" .. libpng_prefix)
        if package:is_plat("windows") then
            table.join2(configs, {"-DWT_WRASTERIMAGE_IMPLEMENTATION=Direct2D", "-DCONNECTOR_ISAPI=ON", "-DENABLE_PANGO=OFF"})
        else
            table.join2(configs, {"-DCONNECTOR_FCGI=OFF", "-DENABLE_PANGO=ON"})
            table.insert(configs, "-DWT_WRASTERIMAGE_IMPLEMENTATION=" .. (package:config("graphicsmagick") and "GraphicsMagick" or "none"))
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBOOST_DYNAMIC=" .. (package:dep("boost"):config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DHARU_DYNAMIC=" .. (package:dep("libharu"):config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        io.replace(path.join(package:installdir("include"), "Wt", "WConfig.h"), [[#define RUNDIR]], [[//#define RUNDIR]], {plain = true})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include <Wt/WApplication.h>
        #include <Wt/WBreak.h>
        #include <Wt/WContainerWidget.h>
        #include <Wt/WLineEdit.h>
        #include <Wt/WPushButton.h>
        #include <Wt/WText.h>
        class HelloApplication : public Wt::WApplication {
            public:
                HelloApplication(const Wt::WEnvironment& env);
            private:
                Wt::WLineEdit *nameEdit_;
                Wt::WText     *greeting_;
                void greet();
        };
        HelloApplication::HelloApplication(const Wt::WEnvironment& env) : WApplication(env) {
            setTitle("Hello world");
            root()->addWidget(std::make_unique<Wt::WText>("Your name, please ? "));
            nameEdit_ = root()->addWidget(std::make_unique<Wt::WLineEdit>());
            nameEdit_->setFocus();
            auto button = root()->addWidget(std::make_unique<Wt::WPushButton>("Greet me."));
            button->setMargin(5, Wt::Side::Left);
            root()->addWidget(std::make_unique<Wt::WBreak>());
            greeting_ = root()->addWidget(std::make_unique<Wt::WText>());
            button->clicked().connect(this, &HelloApplication::greet);
            nameEdit_->enterPressed().connect(std::bind(&HelloApplication::greet, this));
            button->clicked().connect([=]() { std::cerr << "Hello there, " << nameEdit_->text() << std::endl; });
        }
        void HelloApplication::greet() { greeting_->setText("Hello there, " + nameEdit_->text()); }
        int main(int argc, char **argv) {
            return Wt::WRun(argc, argv, [](const Wt::WEnvironment &env) { return std::make_unique<HelloApplication>(env); });
        }
        ]]}, {configs = {languages = "c++20"}}))
    end)
