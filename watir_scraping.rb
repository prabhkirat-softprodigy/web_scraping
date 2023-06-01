# Require the gems we want to use
require 'watir'
require 'webdrivers'
require 'headless'
require 'byebug'
require 'csv'

require './lib/keka'

# Initialize the Browser
# headless = Headless.new
# headless.start

upcomming_birthday_list = []

browser = Watir::Browser.new
browser.goto 'https://softprodigy.keka.com/'
browser.button(text: 'Keka Password').click

#Fill out Text Field Names
browser.text_field(id: 'email').set Keka::EMAIL
browser.text_field(id: 'password').set Keka::PASSWORD

sleep 10 # Time for captcha entering

browser.button(text: 'Login').click

is_log_in = false

while !is_log_in
	begin
		browser.wait_until(timeout: 2) { |b| b.title == "Home | Dashboard" }
		is_log_in = true
	rescue Watir::Wait::TimeoutError => e
		if browser.title == "Keka Login"
			if browser.div(class: "validation-summary-errors", index: 0).text == "Invalid Captcha. Please try again."
				browser.text_field(id: 'password').set Password::VALUE
				sleep 10
				browser.button(text: 'Login').click
			end
		else
			puts e.inspect
		end
	end
end

begin
	emp_list = browser.element(tag_name: "home-upcoming-birthdays").wait_until(&:present?)
	upcomming_birthday_container = emp_list.div(class: "d-flex flex-wrap", index: 0).wait_until(&:present?)
	upcomming_birthday_container.divs(class: "employee-profile-header").each do |emp_profile|
		name = emp_profile.p(class: "text-capitalize").wait_until(&:present?).text
		birthday_date = emp_profile.p(class: "text-secondary").text
		
    upcomming_birthday_list << [name, birthday_date]
	end
rescue Exception => e
	puts e.inspect
end

csv_headers = ["name", "birthday_date"] 
CSV.open("upcomming_birthday.csv", "wb", write_headers: true, headers: csv_headers) do |csv| 
  upcomming_birthday_list.each do |data| 
    csv << data 
  end 
end

# headless.destroy

