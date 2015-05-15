# encoding: utf-8
require './html_reader'

class YueJiHtmlReader < HtmlReader
  def index_url(page)
    "#{@index_url}c#{page}.html"
  end

  def is_article_link?(link)
    link.content.include?('12星座悦己星运')
  end

  def is_next_page_link?(link)
    next_page_url = link.attr('href')
    urls = link.parent.parent.css('a').collect {|page_link| page_link.attr('href')}
    urls.index(next_page_url) != urls.size - 1
  end
end

config = {}
config[:index_url] = "http://life.self.com.cn/balance/horoscope/"
config[:from_page]  = 1
config[:to_page] = 20
config[:index_css_selector] = '.column-smalist a.title'
config[:article_css_selector] = ['.cont-left .title h1', ".cont-left .summary", '.cont-left .article']
config[:article_next_page_css] = '.common-pagenav a.next'

YueJiHtmlReader.new(config).start