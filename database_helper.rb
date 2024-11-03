# frozen_string_literal: true

require 'sequel'
require 'sqlite3'

class DatabaseHelper
  def initialize(db_name)
    @db = Sequel.sqlite(db_name)

    create_table_if_not_exists
  end

  def create_table_if_not_exists
    @db.create_table?(:products) do
      primary_key :id
      String :url
      String :name
      String :price
      String :ai_generated_customer_say
      String :image
      String :category
    end
  end

  def insert_product(product, category)
    @db[:products].insert(
      url: product.url,
      name: product.name,
      price: product.price,
      ai_generated_customer_say: product.ai_generated_customer_say,
      image: product.image,
      category: category
    )
  end

  def close
    @db.disconnect
  end
end
