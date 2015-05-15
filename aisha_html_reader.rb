# encoding: utf-8
require './html_reader'

class AiShaHtmlReader < HtmlReader
  def index_url(page)
    "#{@index_url}#{page}"
  end

  def is_article_link?(link)
    link.content.include?('爱莎塔罗周运')
  end

  def is_next_page_link?(link)
    false
  end
end

config = {}
config[:index_url] = "http://9.self.com.cn/group/513-1-3-"
config[:from_page]  = 1
config[:to_page] = 20
config[:index_css_selector] = '.HotTopic > .title > h2 > a'
config[:article_css_selector] = ['thread-title', '.thread-dateline', '.dynamic-txt']
config[:article_next_page_css] = ''

AiShaHtmlReader.new(config).start