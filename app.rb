require 'sinatra'
require 'wiki/api'

CONFIG = { uri:"http://en.wikipedia.org" }
Wiki::Api::Connect.config = CONFIG


get '/' do
  @post = false
  erb :index
end

def get_page_content(search_query)
  page = Wiki::Api::Page.new(name:search_query)
  to_return = {art_name:"", content:""}
  begin
    headline = page.root_headline

    to_return[:article_name] = headline.name
    to_return[:content] = headline.block.to_texts[0]
    if to_return[:content].include?("Redirect to:")
      to_return = get_page_content(headline.block.to_texts[1])
    end
  rescue StandardError => e
    puts e
    to_return[:article_name] = "Not Found"
    to_return[:content] = "Not Found"
  end
  return to_return
end

post '/' do
  @post = true
  content = get_page_content(params[:topic])

  @article_text = content[:content]
  article_split = @article_text.split(" ")

  @content = ''

  params[:numparas].to_i.times do
    @content+='<p>&nbsp;&nbsp;&nbsp;&nbsp;'
    num_sentences = rand(params[:sentences_max].to_i - params[:sentences_min].to_i).to_i + params[:sentences_min].to_i
    num_sentences.times do
      num_words = rand(12) + 4
      num_words.to_i.times do
        @content+= ' ' + article_split.sample
      end
      @content+='.'
    end
    @content+='</p>'
  end

  @article_name = content[:article_name]
  erb :index
end