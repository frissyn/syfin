#!/usr/bin/env ruby

require "uri"
require "cli/ui"
require "colorize"

require_relative "syfin/actions"
require_relative "syfin/parser"
require_relative "syfin/requests"

module Syfin
    UI = CLI::UI
    VERSION = "0.0.1a"
end

Syfin::UI::StdoutRouter.enable()
Parser = Syfin::MainParser.new

# Split main operations into "pipelines"
# A pipline is defined as a script operation encased
# in an exception handler for expected or common errors.

# PARSING PIPLINE
begin
    args, opts = Parser.parse(ARGV, Syfin::VERSION).finalize()

    if opts[:is_uri]
        args[0] = URI.parse(args[0]).path.split("/")[-1]
    end

    if opts[:verbose]
        puts ("✓ Parsed Options!".green)
        puts args
    end
rescue OptionParser::ParseError => err
    Syfin::UI.puts("ParseError: #{err.message}".red, to: $stderr); exit
end
