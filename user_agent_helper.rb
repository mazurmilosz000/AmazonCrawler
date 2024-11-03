# frozen_string_literal: true

require 'selenium-webdriver'

module UserAgentHelper
  def self.headless_browser_user_agent
    # Set up a headless browser instance using selenium-webdriver
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    driver = Selenium::WebDriver.for :chrome, options: options

    # Open a page to get the user agent
    driver.navigate.to "https://google.com"
    user_agent = driver.execute_script("return navigator.userAgent;")
    driver.quit

    user_agent
  end
end
