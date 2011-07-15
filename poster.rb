#coding:utf-8
require 'oauth'
require 'configatron'
require 'gdata_plus'
require 'nokogiri'

configatron.google.client_id        = ""
configatron.google.client_secret    = ""

# consumer = OAuth::Consumer.new(configatron.google.client_id, configatron.google.client_secret, {
#   :site => "https://www.google.com", 
#   :request_token_path=>"/accounts/OAuthGetRequestToken", 
#   :authorize_path=>"/accounts/OAuthAuthorizeToken", 
#   :access_token_path=>"/accounts/OAuthGetAccessToken"
# })

# request_token = consumer.get_request_token({}, {
#   :scope            => "http://www.blogger.com/feeds/", 
#   :callback   => "http://qengine.com:3000/service/google/oauth"
# })
# 
# puts request_token.token
# puts request_token.secret
# puts request_token.authorize_url


# 
# req = OAuth::RequestToken.new(consumer, t, s).get_access_token(:oauth_verifier => v)
# 
# puts req.inspect

oauth_t = ""
oauth_s = ""

authenticator = GDataPlus::Authenticator::OAuth.new({
  :consumer_key       => configatron.google.client_id, 
  :consumer_secret    => configatron.google.client_secret, 
  :access_token       => oauth_t, 
  :access_secret      => oauth_s  
})

client = authenticator.client

profile_id = "10558051080958897791"

body = Nokogiri::XML(client.get("http://www.blogger.com/feeds/default/blogs").body)

blog_url = false
blogs = []
body.css("entry").each do |entry|
  blogs << {:url => entry.at_css("link")['href'], :title => entry.at_css("title").inner_text}
end

puts "Choose a blog: "
blogs.each_with_index do |blog, index|
  puts (index+1).to_s + " #{blog[:title]}"
end
puts "Select blog"
blog_index = gets

post = %{
  <entry xmlns='http://www.w3.org/2005/Atom'>
    <title type='text'>Marriage!</title>
    <content type='xhtml'>
      <div xmlns="http://www.w3.org/1999/xhtml">
        <p>Mr. Darcy has <em>proposed marriage</em> to me!</p>
        <p>He is the last man on earth I would ever desire to marry.</p>
        <p>Whatever shall I do?</p>
      </div>
    </content>
    <category scheme="http://www.blogger.com/atom/ns#" term="marriage" />
    <category scheme="http://www.blogger.com/atom/ns#" term="Mr. Darcy" />
  </entry>
}

post_url = "http://www.blogger.com/feeds/%s/posts/default" % blogs[blog_index.to_i-1][:url].split("/").last

client.post(post_url,:body => post, :headers => {'content-type' => "application/atom+xml"})