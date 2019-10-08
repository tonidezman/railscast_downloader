require 'open-uri'
require 'capybara'
require 'pry'

BASE_URL        = "http://railscasts.com/"
DOWNLOAD_FOLDER = "/Users/tonidezman/Desktop/RailsCasts/"

class Downloader
  def self.start
    capybara_configuration
    browser  = Capybara.current_session

    video_links = []
    pages = (1..48)
    pages.each do |page|
      browser.visit("#{BASE_URL}?page=#{page}")
      browser.find_all(".pretty_button").each.with_index do |a_tag, i|
        video_links << a_tag[:href]
      end
    end

    video_links.each do |video_link|
      file_name = browser.title.gsub(" ", "_").gsub(/[^\w]/, "")
      browser.visit(video_link)
      browser.click_link("mp4")
      url = browser.current_url
      browser.go_back

      file_path = "#{DOWNLOAD_FOLDER}#{file_name}.mp4"
      next if File.exist?(file_path)

      open(file_path, "wb") do |file|
        file.print open(url).read
      end
    end

    Capybara.current_session.driver.quit
  end

  private

  def self.capybara_configuration
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(app, browser: :firefox)
    end
    Capybara.javascript_driver = :firefox
    Capybara.configure do |config|
      config.default_max_wait_time = 10 # seconds
      config.default_driver = :selenium
    end
  end

end

Downloader.start
