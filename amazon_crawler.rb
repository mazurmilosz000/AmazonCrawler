# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'uri'
require_relative 'user_agent_helper'
require_relative 'product'
require_relative 'database_helper'

class AmazonCrawler
  BASE_URL = "https://www.amazon.com/s?k="
  DEFAULT_CATEGORIES = %w[laptop headphones smartphone tablet gaming+console smartwatch camera]

  def initialize(categories = nil)
    @categories = categories || [DEFAULT_CATEGORIES.sample]
    @user_agent = UserAgentHelper.headless_browser_user_agent
    @db_helper = DatabaseHelper.new('products.db')
  end

  def build_amazon_search_url
    search_query = @categories.map { |category| URI.encode_www_form_component(category) }.join("+")
    "#{BASE_URL}#{search_query}"
  end

  def fetch_web_page(url)
    puts "Generated url: #{url}"

    response = HTTParty.get(url, headers: { "User-Agent" => @user_agent})
    response_code = response.code

    if response_code == 200
      puts "Successfully fetched Amazon page!"
      response.body
    else
      puts "Failed to fetch Amazon page. Status code: #{response_code}"
      nil
    end
  end

  def parse_results(html)
    products = []
    parsed_page = Nokogiri::HTML(html)
    product_links = parsed_page.css('a.a-link-normal.s-no-outline')
    links = product_links.map { |link| link['href'] }

    products_count = links.length
    puts "Found #{products_count} products"

    i = 0
    links.each do |link|
      puts "Processing item: #{i+=1}/#{products_count}"
      product = get_product_info(link)
      products.push(product)

      @db_helper.insert_product(product, @categories.join(" "))
    end

    products
  end

  def get_product_info(link)
    product_link = "https://amazon.com#{link}"
    product_html = fetch_web_page(product_link)
    if product_html
      parsed_product_html = Nokogiri::HTML(product_html)

      url = product_link
      name = parsed_product_html.css('span#productTitle').text.strip

      price_whole = parsed_product_html.css('span.a-price-whole').text.strip.split('.')[0] || ""
      price_fraction = parsed_product_html.css('span.a-price-fraction').text.strip.slice(0, 2) || ""
      price = "#{price_whole}.#{price_fraction}" unless price_whole.empty? || price_fraction.empty?

      ai_generated_customer_say = parsed_product_html.css('p.a-spacing-small span').map(&:text).join(", ") unless parsed_product_html.css('p.a-spacing-small span').empty?
      image = parsed_product_html.css('div.imgTagWrapper img').first['src'] if parsed_product_html.css('div.imgTagWrapper img').any?

      Product.new(url, name, price, ai_generated_customer_say, image)
    end
  end

  def run
    html = fetch_web_page(build_amazon_search_url)
    if html
      products = parse_results(html)
      puts "Crawled items: #{products}"
    end
  end

  def close_database
    @db_helper.close
  end

  if __FILE__ == $PROGRAM_NAME
    categories = ARGV.empty? ? nil : ARGV
    scraper = AmazonCrawler.new(categories)
    scraper.run
    scraper.close_database
  end
end
