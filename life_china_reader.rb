# encoding: utf-8
require 'nokogiri'
require 'open-uri'
# http://search1.china.com.cn/search/searchcn.jsp?searchText=每日运程分析&page=12
class Reader
  SITE_URL = 'http://life.china.com.cn/'
  INDEX_URL = "#{SITE_URL}/node_7197697"

  def start
    page = 1
    @dir = "#{Time.now.strftime '%Y-%m-%d'}"
    @file_name = "#{Time.now.strftime '%Y-%m-%d'}.txt"
    @log_file_name = "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'}.csv"

    while true do
      log ''
      html_text = get_index(page)
      if has_articles?(html_text)
        articles = parse_articles(html_text)
        articles.each do |article|
          save_article(article)
        end
      else
        break
      end

      page += 1
    end
  end

  def get_index(page)
    url = INDEX_URL
    if page > 1
      url += "_#{page}.htm"
    else
      url += ".htm"
    end

    log "GET index #{url}"
    html_text = Nokogiri::HTML(open(url))

    return html_text
  end

  def has_articles?(html_text)
    size = html_text.css('.box > .box2 > ul > li').size

    return size > 0
  end

  def parse_articles(html_text)
    articles = []
    links = html_text.css('.box > .box2 > ul > li > a')
    log "#{links.size}"
    links.each do |link|
      title = link.content
      url   = link.attr('href')
      articles << {title: title, url: "#{SITE_URL}#{url}"} if title.start_with?('[星座]')
    end

    articles
  end

  def save_article(article)
    title = article[:title]
    url   = article[:url]

    log("GET article, #{title}, #{url}")

    html_text = Nokogiri::HTML(open(url, :read_timeout => 20))
    save_article_part(html_text)
    save_next_article(article, html_text)
  end

  def save_next_article(current_article, html_text)
    url = current_article[:url]
    title = current_article[:title]
    next_page_link = html_text.css('#autopage a').last
    if next_page_link.content == '下一页'
      page = url.split('/').last
      href = url.gsub(page, next_page_link.attr('href'))
      part_html_text = Nokogiri::HTML(open(url, :read_timeout => 20))
      article = {title: title, url: href}
      save_article(article)
    end
  end

  def save_article_part(html_text, with_title=true)
    h_title = html_text.css('.box2 .Left h1')[0]
    h_content = html_text.css('#artbody')[0]

    title = h_title ? h_title.content : ''
    content = h_content ? h_content.content : ''

    # Dir.mkdir(@dir) unless File.exist?(@dir)

    file = File.open(@file_name, 'a')
    file.puts "\n\n#{title.strip if with_title}\n#{content.strip}"
    file.close
  rescue => e
    log "Error! article, #{title}, #{url}"
    log e.backtrace.join("\n")
  end

  def log(text)
    puts text.gsub(",", "\t")
    @log_file = File.open(@log_file_name, 'a') if @log_file.nil?
    @log_file.puts text
  end

end

Reader.new.start()