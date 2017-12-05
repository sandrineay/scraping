require 'open-uri'
require 'nokogiri'
require 'mechanize'
require 'csv'

# 1. Create a 'members.json' file at the same level as the file path of this 'emails_meetup_scraper.rb'
# 2. Install some gems. Open your terminal and run: 'gem install nokogiri', 'gem install mechanize', 'gem install json'
# 3. Give us the following information:

# Your Meetup credentials as strings - you need to be an administrator for your Meetup Group
signin_email = 'adresse.stuff@email.com'
signin_password = 'your_meetup_password'

# Number of members on your meetup group as an integer
meetup_members_nb = 1753

# Your meetup group urlname as a string: in https://www.meetup.com/Le-Wagon-Berlin-Coding-Bootcamp/ it's Le-Wagon-Berlin-Coding-Bootcamp
urlname = 'Le-Wagon-Berlin-Coding-Bootcamp'

# 4. Then launch 'ruby emails_meetup_scraper.rb', wait for the "All done!" success message
# 5. Once you're done open "members.csv" and there you go, all your meetup members who chose to give you an email address are in there!

##### DO NOT MODIFY THE FOLLOWING CODE 👇 #####

# On each page, find the URL redirecting to the show page of the member. Store all those URLs in an array

item_counter = 0
member_urls = []
page_counter = 0

for i in 0..(meetup_members_nb / 20)
  url = "https://www.meetup.com/#{urlname}/members/?offset=#{item_counter}&sort=last_visited&desc=1"
  html_file = open(url).read
  html_doc = Nokogiri::HTML(html_file)

  html_doc.search('a.memName').each do |member_link|
    member_urls << member_link.attribute('href').value
  end
  item_counter += 20
  page_counter += 1
  p "#{page_counter} pages"
end

# First you need to login

agent = Mechanize.new
agent.get('https://secure.meetup.com/login/?_locale=fr-FR') do |page|
  form = agent.page.forms[1]
  agent.page.forms[1]['email'] = signin_email
  agent.page.forms[1]['password'] = signin_password
  agent.page.forms[1].submit
end

# Then you can iterate over each of your meetup profile page to get the email addresses.

member_counter = 0
filepath = 'members.csv'
csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }

CSV.open(filepath, 'wb', csv_options) do |csv|
  member_urls.each do |member_url|
    agent.get(member_url) do |page|
      email = page.search('.D_memberProfileContentItem p')[2].text
      if email =~ /@/
        name = page.search('span.memName.fn')[0].text
        csv << [name, email]
        member_counter += 1
        p "#{member_counter} members"
      end
    end
  end
end

p "All done!"
