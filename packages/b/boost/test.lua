function _iostreams(package, snippets)
    if not package:config("iostreams") then
        return
    end

    if package:config("zstd") then
        table.insert(snippets,
            [[
                #include <boost/iostreams/filter/zstd.hpp>
                #include <boost/iostreams/filtering_stream.hpp>
            #if defined(BOOST_NO_EXCEPTIONS)
                namespace boost { BOOST_NORETURN inline void throw_exception(std::exception const & e) {} }
            #endif
                void test() {
                    boost::iostreams::filtering_ostream out;
                    out.push(boost::iostreams::zstd_compressor());
                }
            ]]
        )
    end

    if package:config("lzma") then
        table.insert(snippets,
            [[
                #include <boost/iostreams/filter/lzma.hpp>
                #include <boost/iostreams/filtering_stream.hpp>
            #if defined(BOOST_NO_EXCEPTIONS)
                namespace boost { BOOST_NORETURN inline void throw_exception(std::exception const & e) {} }
            #endif
                void test() {
                    boost::iostreams::filtering_ostream out;
                    out.push(boost::iostreams::lzma_compressor());
                }
            ]]
        )
    end
end

function _filesystem(package, snippets)
    if package:config("filesystem") then
        table.insert(snippets,
            [[
                #include <boost/filesystem.hpp>
                #include <iostream>
            #if defined(BOOST_NO_EXCEPTIONS)
                namespace boost { BOOST_NORETURN inline void throw_exception(std::exception const & e) {} }
            #endif
                void test() {
                    boost::filesystem::path path("/path/to/directory");
                    if (boost::filesystem::exists(path)) {
                        std::cout << "Directory exists" << std::endl;
                    } else {
                        std::cout << "Directory does not exist" << std::endl;
                    }
                }
            ]]
        )
    end
end

function _date_time(package, snippets)
    if package:config("date_time") then
        table.insert(snippets,
            [[
                #include <boost/date_time/gregorian/gregorian.hpp>
            #if defined(BOOST_NO_EXCEPTIONS)
                namespace boost { BOOST_NORETURN inline void throw_exception(std::exception const & e) {} }
            #endif
                void test() {
                    boost::gregorian::date d(2010, 1, 30);
                }
            ]]
        )
    end
end

function _header_only(package, snippets)
    table.insert(snippets,
        [[
            #include <boost/algorithm/string.hpp>
            #include <string>
            #include <vector>
        #if defined(BOOST_NO_EXCEPTIONS)
            namespace boost { BOOST_NORETURN inline void throw_exception(std::exception const & e) {} }
        #endif
            void test() {
                std::string str("a,b");
                std::vector<std::string> vec;
                boost::algorithm::split(vec, str, boost::algorithm::is_any_of(","));
            }
        ]]
    )
    table.insert(snippets,
        [[
            #include <boost/unordered_map.hpp>
        #if defined(BOOST_NO_EXCEPTIONS)
            namespace boost { BOOST_NORETURN inline void throw_exception(std::exception const & e) {} }
        #endif
            void test() {
                boost::unordered_map<std::string, int> map;
                map["2"] = 2;
            }
        ]]
    )
end

function main(package)
    local snippets = {}

    if package:config("header_only") then
        _header_only(package, snippets)
    else
        if not package:config("cmake") then
            _header_only(package, snippets)
        end
        _iostreams(package, snippets)
        _filesystem(package, snippets)
        _date_time(package, snippets)
    end

    local opt = {configs = {languages = "c++14"}}
    for _, snippet in ipairs(snippets) do
        assert(package:check_cxxsnippets({test = snippet}, opt))
    end
end
