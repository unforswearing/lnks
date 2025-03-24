#!/usr/bin/env ruby

program = "main.sh"

test_queries = [
  "test",
  "mail",
  "bash",
  "bandcamp|spotify",
  "git(hub|lab)",
  "^portal.*",
  "^docs.*",
  "\.io\/"
]

program_flags = [
  "",
  "--print",
  "--markdown",
  "--html",
  "--csv"
]

output_patterns = {
  "empty" => "//g",
  "--print" => "match plain url",
  "--markdown" => "match square brace and parens, enclosing text",
  "--html" => "match tag names, href value, tag content text",
  "--csv" => "match header pattern, match each rows pattern"
}

program_flags.each do |flag|
  test_queries.each do |query|
    # output = `#{program} #{query} #{flag}`
    # if output.match(ouput_patterns[flag])
    #   puts "PASS: #{program} (#{query}) -> #{flag}"
    # else
    #    puts "FAIL: #{program} (#{query}) -> #{flag}"
  end
end