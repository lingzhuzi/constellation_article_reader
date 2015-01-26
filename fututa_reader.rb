# encoding: utf-8
require 'nokogiri'
require 'open-uri'

class Reader
  def start
    page = 1
    @log_file_name = "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'}.csv"

    while true do
      log ''
      html_text = get_index(page)
      if has_articles?(html_text)
        articles = parse_articles(html_text)
        articles.each do |article|
          get_article(article)
        end
      else
        break
      end

      page += 1
    end
  end

  def get_index(page)
    url = "http://www.fututa.com/guoxue"
    if page > 1
      url += "/l_#{page}.html"
    end

    log "GET index #{url}"
    html_text = Nokogiri::HTML(open(url))

    return html_text
  end

  def has_articles?(html_text)
    size = html_text.css('.articles > .item').size

    return size > 0
  end

  def parse_articles(html_text)
    articles = []
    html_text.css('.articles > .item').each do |item|
      meta  = item.css('.meta').text
      link  = item.css('.title > a')
      title = link.attr('title').value
      url   = link.attr('href').value
      articles << {title: title, meta: meta, url: "http://fututa.com#{url}"}
    end

    articles
  end

  def get_article(article)
    title = article[:title]
    url   = article[:url]
    meta  = article[:meta]

    if(meta.start_with?('小滢'))
      # open(url)
      `'/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome' #{url}`
      log("GET article, #{title}, #{meta}, #{url}")
    else
      log "ignore article, #{title}, #{meta}, #{url}"
    end
  rescue => e
    log "Error! article, #{title}, #{meta}, #{url}"
    log e.backtrace.join("\n")
  end

  def log(text)
    puts text.gsub(",", "\t")
    @log_file = File.open(@log_file_name, 'a') if @log_file.nil?
    @log_file.puts text
  end

end

Reader.new.start()