# encoding: utf-8
require 'nokogiri'
require 'open-uri'

class HtmlReader

  def initialize(config)
    @doc_dir = 'doc'
    @log_dir = 'log'
    @file_name = "#{Time.now.strftime '%Y-%m-%d--%H-%M-%S'}.txt"
    @log_file_name = "#{Time.now.strftime '%Y-%m-%d %H:%M:%S'}.csv"
    raise "Missing index url" if config[:index_url].nil?
    @index_url = config[:index_url]
    @from_page = config[:from_page] || 0
    @to_page   = config[:to_page] || 100
    @index_css = config[:index_css_selector]
    @article_css = config[:article_css_selector]
    @article_next_page_css = config[:article_next_page_css]
  end

  def complete_url(current_url, url)
    if url.start_with?('http://') || url.start_with?('https://')
      return url
    elsif url.start_with?('/')
      url[0] = ''
      url_arr = url.split('/')[1, 3]
      url_arr[3] = url
      return url_arr.join('/')
    else
      url_arr = current_url.split('/')
      url_arr[url_arr.size - 1] = url
      return url_arr.join('/')
    end
  end

  def index_url(page)
    raise 'Implement this in a subclass!'
  end

  def is_next_page_link?(link)
    raise 'Implement this in a subclass!'
  end

  def is_article_link?(link)
    raise 'Implement this in a subclass!'
  end

  def save_to_default_file?
    true
  end

  def start
    (@from_page..@to_page).each do |page|
      html_text = get_index_page(page)

      articles = parse_index_page(html_text)
      articles.each do |article|
        save_article(article)
        save_article_to_file(article[:title], '-'*50)
      end
    end
  end

  def get_page(url)
    retry_times = 0
    html_text = nil
    begin
      html_text = Nokogiri::HTML(open(url, :read_timeout => 60))
    rescue => e
      if retry_times < 5
        retry_times += 1
        retry
      else
        log e.message
        log "error occurred when load page: #{url}"
        log e.backtrace.join("\n")
      end
    ensure
      return html_text
    end
  end

  def get_index_page(page)

      url = index_url(page)

      log "GET index #{url}"
      html_text = get_page(url)

      return html_text

  end

  def valid_url?(url)
    url = url.downcase
    if url.start_with?('#') || url.start_with?('javascript')
      return false
    end
    return true
  end

  def parse_index_page(html_text)
    articles = []
    links = html_text.css(@index_css)
    links.each do |link|
      title = link.content || link.attr('title')
      url   = link.attr('href')
      if valid_url?(url) && is_article_link?(link)

        articles << {title: title, url: complete_url(@index_url, url)}
      end
    end

    articles
  end

  def save_article(article)
    title = article[:title]
    url   = article[:url]

    log("GET article, #{title}, #{url}")

    html_text = get_page(url)
    if html_text
      save_article_to_file(title, html_text)
      save_next_article(article, html_text)
    end
  end

  def save_next_article(current_article, html_text)
    url = current_article[:url]
    title = current_article[:title]
    if @article_next_page_css && @article_next_page_css != ''
      next_page_link = html_text.css(@article_next_page_css).last
      if next_page_link && is_next_page_link?(next_page_link)
        href = next_page_link.attr('href')
        article_url = complete_url(url, href)
        part_html_text = get_page(article_url)
        article = {title: title, url: article_url}
        save_article(article)
      end
    end
  end

  def save_article_to_file(title, html_text)
    Dir.mkdir(@doc_dir) unless File.exist?(@doc_dir)
    @file_name = title unless save_to_default_file?

    file = File.open("#{@doc_dir}/#{@file_name}.txt", 'a')
    @article_css.each do |css|
      items = html_text.css(css)
      items.each do |item|
        file.puts item.content
      end
    end

    file.puts '-'*50 if save_to_default_file?
    file.close
  end

  def log(text)
    Dir.mkdir(@log_dir) unless File.exist?(@log_dir)
    puts text.gsub(",", "\t")
    log_file = File.open("#{@log_dir}/#{@log_file_name}", 'a')
    log_file.puts text
    log_file.close
  end

end
