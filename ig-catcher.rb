require "sinatra"
require "instagram"
require 'dotenv'
Dotenv.load

enable :sessions

CALLBACK_URL = "http://localhost:4567/oauth/callback"

Instagram.configure do |config|
  config.client_id = ENV['IG_CLIENT_ID']
  config.client_secret = ENV['IG_CLIENT_SECRET']
end

get "/" do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(redirect_uri: CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], redirect_uri: CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/user_recent_media"
end

get "/user_recent_media" do
  client = Instagram.client(access_token: session[:access_token])
  user = client.user
  html = "<h1>#{user.username}'s last pic</h1>"
  html << "<img src='#{client.user_recent_media.first.images.standard_resolution.url}'>"

end