require 'nokogiri'
require 'open-uri'

class Reader
  INDEX_URL = 'http://www.styletv.com.cn/horoscope/today'

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
      url += "/pl-pn-#{page}.shtml"
    end

    log "GET index #{url}"
    html_text = Nokogiri::HTML(open(url))

    return html_text
  end

  def has_articles?(html_text)
    size = html_text.css('#text_list > .used_left3').size

    return size > 0
  end

  def parse_articles(html_text)
    articles = []
    html_text.css('#text_list > .used_left3').each do |item|
      link  = item.css('.used_left3_3_1 > a')
      title = link.attr('title').value
      url   = link.attr('href').value
      articles << {title: title, url: url}
    end

    articles
  end

  def save_article(article)
    title = article[:title]
    url   = article[:url]

    html_text = Nokogiri::HTML(open(url, :read_timeout => 20))
    h_title = html_text.css('.main_s > .titlea')[0]
    h_txt_q = html_text.css('.main_s > .txt_q')[0]
    h_content = html_text.css('.main_s > .midd_midd')[0]

    title = h_title ? h_title.content : ''
    txt_q = h_txt_q ? h_txt_q.content : ''
    content = h_content ? h_content.content : ''

    Dir.mkdir(@dir) unless File.exist?(@dir)

    file = File.open(@file_name, 'a')
    file.puts "#{title.strip}\n#{txt_q.strip}\n#{content.strip}"
    file.close

    log("GET article, #{title}, #{url}")
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