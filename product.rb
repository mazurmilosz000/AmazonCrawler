# frozen_string_literal: true

class Product
  attr_accessor :url, :name, :price, :ai_generated_customer_say, :image

  def initialize(url = nil, name = nil, price = nil, ai_generated_customer_say = nil, image = nil)
    @url = url
    @name = name
    @price = price
    @ai_generated_customer_say = ai_generated_customer_say
    @image = image
  end

  def to_s
    "URL: #{@url}, Name: #{@name}, Price: #{@price}, Reviews: #{@ai_generated_customer_say}, Image: #{@image}"
  end
end

