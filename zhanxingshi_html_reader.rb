# encoding: utf-8
require './html_reader'

class ZhanxingshiHtmlReader < HtmlReader
  def index_url(page)
    "#{@index_url}#{page}"
  end

  def is_article_link?(link)
    true
  end

  def is_next_page_link?(link)
    false
  end
end

config = {}
config[:index_url] = "http://www.zhanxingshi.cc/search.php?mod=portal&searchid=4&searchsubmit=yes&kw=%BD%A1%BF%B5%D4%CB&page="
config[:from_page]  = 1
config[:to_page] = 3
config[:index_css_selector] = '#ct .tl .slst ul li h3 a'
config[:article_css_selector] = ['#ct .mn .bm .hm', '#ct .mn .bm .s', '#article_content > font > b', '#article_content p']
config[:article_next_page_css] = ''

ZhanxingshiHtmlReader.new(config).start