# このファイルを追加したら、ポロポロこけていたfeature specが通るようになった… 原因不明…
# http://tech.speee.jp/entry/2017/06/15/135636

require 'capybara/rspec'
require 'selenium-webdriver'

# Capybara.register_driver :selenium do |app|
#   Capybara::Selenium::Driver.new(app,
#                                  browser: :chrome,
#                                  desired_capabilities: Selenium::WebDriver::Remote::Capabilities.chrome(
#                                      chrome_options: {
#                                          # args: %w(headless disable-gpu window-size=1000,600),
#                                          # window-sizeの設定があると、どうもAttacksのテストでエラーになる。Timeoutしてるのか。
#                                          args: %w(headless disable-gpu),
#                                      },
#                                      )
#   )
# end

# https://github.com/JunichiIto/rails-5-1-system-test-sandbox/blob/with-rspec/spec/rails_helper.rb
Chromedriver.set_version "2.33"
caps = Selenium::WebDriver::Remote::Capabilities.chrome("chromeOptions" => {"args" => %w(headless disable-gpu)})
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: caps)
end

# ここの記述も足してみた
# https://mikecoutermarsh.com/rails-capybara-selenium-chrome-driver-setup/

Capybara.javascript_driver = :selenium

Capybara.configure do |config|
  config.default_max_wait_time = 20 # seconds
  config.default_driver        = :selenium
end
