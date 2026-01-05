#########################################################################
# Complete HSK Vocabulary
# ------------
# Script to process the complete dataset into minified 
# and level-based lists.
#
# Usage:
#   ruby scripts/process.rb [--dry-run]
#
# Copyright (c) 2026 Yanis Zafirópulos (aka Dr.Kameleon)
# Licensed under the MIT License.
#########################################################################

require 'bundler/setup'

require 'colorize'

script_dir = __dir__
root_dir = File.expand_path("..", script_dir)

dry_run = ARGV.include?("--dry-run")
dry_flag = dry_run ? " --dry-run" : ""

def header(title)
    puts "----------------------------------------------------------------------".bold.cyan
    puts title.bold.cyan
    puts "----------------------------------------------------------------------".bold.cyan
end

def success 
    puts " [ ✔ OK ]".green
end

if dry_run
    puts "🔍 DRY RUN MODE - No files will be written".bold.yellow
    puts ""
end

header("Processing main dataset")
print "- Compressing list...       "
`ruby #{script_dir}/minify.rb #{root_dir}/complete.json#{dry_flag}`
success()

[
    ["old", 1..6],
    ["new", 1..7]
].each{|scheme, levels|
    cumulative = []
    puts "\n"
    header("Processing #{scheme} levels")
    levels.each{|x|
        puts "\tLevel: #{x}".yellow
        print "\t\t- Filtering exclusive list  "
        `ruby #{script_dir}/filter.rb exclusive #{scheme}-#{x}#{dry_flag}`
        success()
        cumulative << "#{scheme}-#{x}"
        print "\t\t- Filtering inclusive list  "
        `ruby #{script_dir}/filter.rb inclusive #{cumulative.join(" ")}#{dry_flag}`
        success()

        print "\t\t- Compressing lists...      "
        `ruby #{script_dir}/minify.rb #{root_dir}/wordlists/exclusive/#{scheme}/#{x}.json#{dry_flag}`
        `ruby #{script_dir}/minify.rb #{root_dir}/wordlists/inclusive/#{scheme}/#{x}.json#{dry_flag}`
        success()
    }
}