require "httparty" 
require "nokogiri" 
require 'byebug'

# defining a data structure to store the scraped data 

# Product = Struct.new(:url, :image, :name, :price) 
 
all_products = [] 
 
current_page = 1 

total_pages = 5
 
while current_page <= total_pages do 
  url = "https://scrapeme.live/shop/page/#{current_page}/"

  response = HTTParty.get(url)
 
  parsed_document = Nokogiri::HTML(response.body)   # parsing the HTML document returned by the server 
  html_products = parsed_document.css("li.product") # selecting all HTML product elements


  puts "Current Page = #{current_page}, page_url = #{url}, Products count = #{html_products.count}"

  # iterating over the list of HTML products 
  html_products.each do |html_product| 
    url = html_product.css("a").first.attribute("href").value 
    image = html_product.css("img").first.attribute("src").value 
    name = html_product.css("h2").first.text 
    price = html_product.css("span").first.text

    all_products.push([url, image, name, price]) 
  end 
 
  current_page += 1 
end 
 
 puts "All products  count = #{all_products.count}"
# Store into CSV file 
csv_headers = ["url", "image", "name", "price"] 
CSV.open("output.csv", "wb", write_headers: true, headers: csv_headers) do |csv| 
  all_products.each do |product| 
    csv << product 
  end 
end