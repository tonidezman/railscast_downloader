require 'open-uri'
require 'capybara'
require 'pry'

class Downloader
  def self.start
    capybara_configuration
    base_url = "http://railscasts.com/"
    browser  = Capybara.current_session

    video_links = []
    all_pages = (1..48)
    all_pages.each do |page|
      browser.visit("#{base_url}?page=#{page}")
      browser.find_all(".pretty_button").each.with_index do |a_tag, i|
        video_links << a_tag[:href] if i.odd?
      end
    end

    video_links.each do |video_link|
      file_name = browser.title.gsub(" ", "_")
      browser.visit(video_link)
      browser.click_link("mp4")
      url = browser.current_url
      browser.go_back

      file_path = "/Users/tonidezman/Desktop/RailsCasts/#{file_name}.mp4"
      open(file_path, "wb") do |file|
        file.print open(url).read
      end
      return
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
