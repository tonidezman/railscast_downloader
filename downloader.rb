require 'open-uri'
require 'capybara'
require 'pry'

class Downloader
  def self.start
    capybara_configuration
    base_url = "http://railscasts.com/"
    browser  = Capybara.current_session

    video_links = []
    all_pages = (1..1)
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



    end

    raise

    # Old code

    doc = Nokogiri::HTML.parse(browser.html)

    current_date = Date.today.to_s
    doc.css('.detail-table__row').each.with_index do |flight_row, index|
      header_or_date = (index == 0 || index == 1)
      next if header_or_date

      time        = flight_row.css('.fdabf-td1').text
      flight_code = flight_row.css('.fdabf-td3').text
      terminal    = flight_row.css('.fdabf-td4').text
      gate        = flight_row.css('.fdabf-td5').text
      airline     = flight_row.css('.fdabf-td6').text
      status      = flight_row.css('.fdabf-td7').text
      destination = flight_row.css('.fdabf-td2 .hidden-xs').text

      # next if status != 'airborne'
      flight = Flight.find_or_initialize_by(
        gate: gate,
        airline: airline,
        terminal: terminal,
        flight_code: flight_code,
        destination: destination,
        airborne_at: DateTime.parse("#{current_date} #{time}")
      )
      flight.status = status

      unless flight.save
        msg = <<~EOL
          ERROR while saving flight
          airborne_at: #{current_date} #{time}
          destination: #{destination}
          status:      #{status}
        EOL
        Rails.logger.error(msg)
      end

      Capybara.current_session.driver.quit
    end

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
