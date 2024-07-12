require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |line, index|
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
end

def chapters_matching(query)
  results = []

  return results unless query

  each_chapter do |number, name, contents|
    matches = {}
    contents.split("\n\n").each_with_index do |paragraph, index|
      matches[index] = paragraph if paragraph.include?(query)
    end
    results << {number: number, name: name, paragraphs: matches} if matches.any?
  end

  results
end

before do
  @contents = File.readlines("data/toc.txt")
end

get "/" do
  @title = "The Adventures of This One Dude"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  @chapter = "Chapter #{number}"
  @title = @contents[number - 1]

  redirect "/" unless (1..@contents.size).cover? number

  @chapter_text = File.read("data/chp#{number}.txt")

  erb :chapter
end

def search_chapters(query)
  @files = Dir.glob("data/*")
  @results = []
  @files.each do |file|
    @results << file if File.read(file.to_s).match(query)
  end
end

get "/search" do
  search_chapters(params[:query]) if params[:query]

  erb :search
end

not_found do
  "Looks Like there is not a page for that!"
end
