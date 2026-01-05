script_dir = __dir__
root_dir = File.expand_path("..", script_dir)

puts "- Compressing complete.json"
`ruby #{script_dir}/minify.rb #{root_dir}/complete.json`

[
    ["old", ["1","2","3","4","5","6"]],
    ["new", ["1","2","3","4","5","6","7+"]]
].each{|scheme, levels|
    cumulative = []
    
    levels.each{|x|
        puts "- Creating sublist for #{scheme} level: #{x}..."
        `ruby #{script_dir}/filter.rb exclusive #{scheme}-#{x}`
        cumulative << "#{scheme}-#{x}"
        puts "Calling: ruby #{script_dir}/filter.rb inclusive #{cumulative.join(" ")}"
        `ruby #{script_dir}/filter.rb inclusive #{cumulative.join(" ")}`

        puts "\t - Compressing..."
        `ruby #{script_dir}/minify.rb #{root_dir}/wordlists/exclusive/#{scheme}/#{x}.json`
        `ruby #{script_dir}/minify.rb #{root_dir}/wordlists/inclusive/#{scheme}/#{x}.json`
    }
}