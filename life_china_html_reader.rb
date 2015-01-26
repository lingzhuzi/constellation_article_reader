# encoding: utf-8
require './html_reader'

class LifeChinaHtmlReader < HtmlReader
  def index_url(page)
    "#{@index_url}#{page}"
  end

  def is_article_link?(link)
    link.content.start_with?('[星座]')
  end

  def is_next_page_link?(link)
    link.content == '下一页'
  end
end

config = {}
config[:index_url] = "http://search1.china.com.cn/search/searchcn.jsp?searchText=%E6%AF%8F%E6%97%A5%E8%BF%90%E7%A8%8B%E5%88%86%E6%9E%90&page="
config[:from_page]  = 1
config[:to_page] = 3
config[:index_css_selector] = 'table tr > td > a[href^="http://life.china.com.cn/"]'
config[:article_css_selector] = ['.box2 .Left h1', '#artbody']
config[:article_next_page_css] = '#autopage a'

LifeChinaHtmlReader.new(config).start