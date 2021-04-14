require "uri"
require "colorize"
require "optparse"

module Syfin
    class MainParser
        def parse(args, version)
            @options = ScriptOptions.new
            
            @args = OptionParser.new do |pr|
                @options.def_options(pr, version)
                pr.parse!(args)
            end

            return @options
        end

        class ScriptOptions
            attr_accessor \
                :target,
                :is_uri,
                :verbose

            def initialize
                self.is_uri = true
                self.verbose = false
                self.target = "Syfins"
            end

            def finalize
                return [
                    ARGV,
                    {
                        :target => self.target,
                        :is_uri => self.is_uri,
                        :verbose => self.verbose
                    }
                ]
            end

            def def_options(parser, version)
                parser.banner = "Usage: syfin [options]"
                parser.separator("")
                parser.separator("Options:")
                
                is_uri_option?(parser)
                target_option?(parser)
                verbose_option?(parser)

                parser.on_tail("-h", "--help", "Displays this message.") do
                    puts parser
                    exit
                end

                parser.on_tail("--version", "Displays current version.") do
                    print "Syfin: #{VERSION}\nRuby: #{RUBY_VERSION}\n".green
                    exit
                end

                return true
            end

            def is_uri_option?(parser)
                parser.on("--id", "Parse given value as ID, instead of URL.") do
                    self.is_uri = false
                end
            end

            def verbose_option?(parser)
                parser.on("-v", "--verbose", "Increase verbosity of output.") do
                    self.verbose = true
                end
            end

            def target_option?(parser)
                parser.on("--target=TARGET", String, "Target directory to download results.") do |v|
                    self.target = v
                end
            end
        end
    end
end
