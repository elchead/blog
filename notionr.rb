# https://rubygems.org/gems/notion
# https://github.com/bkeepers/dotenv
require 'dotenv/load'
require 'notion_api'
Dotenv.load('notion.env')
@client = NotionAPI::Client.new(ENV["NOTION_TOKEN_V2"],ENV["NOTION_HEADER"])
okrs = @client.get_page("https://www.notion.so/adrian99/46639aab7aa947648257ecc8b3c3bbb6?v=95e21fe578db4525a0f340bb03037c0b")
#blog = okrs.row("9e0dab6e-9b54-4a2b-8e21-60ae237d9fc9")
#okrs.rows.each { |row|  puts (row.objective) }
#print(blog.target)