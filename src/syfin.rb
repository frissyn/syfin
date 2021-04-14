#!/usr/bin/env ruby

require 'uri'
require 'cli/ui'
require 'colorize'

require_relative 'syfin/actions'
require_relative 'syfin/parser'
require_relative 'syfin/requests'

module Syfin
    UI = CLI::UI
    VERSION = "0.0.1a".freeze
end

Syfin::UI::StdoutRouter.enable
Parser = Syfin::MainParser.new

# Split main operations into "pipelines"
# A pipline is defined as a script operation encased
# in an exception handler for expected or common errors.

# PARSING PIPLINE
begin
    args, opts = Parser.parse(ARGV, Syfin::VERSION).finalize()

    if opts[:is_uri]
        target = URI.parse(args[0]).path.split('/')
        args[0] = "#{target[-2]}s:#{target[-1]}"
    else
        pass = /(tracks|playlists|albums):(.){22}/.match?(args[0])

        unless pass
            Syfin::UI.puts("ParseError: Invalid Spotify ID format.".red, to: $stderr)
            exit(1)
        end
    end

    if opts[:verbose]
        puts("✓ Parsed Options!".green)
    end
rescue OptionParser::ParseError => e
    Syfin::UI.puts("ParseError: #{e.message}".red, to: $stderr)
    exit(1)
end
