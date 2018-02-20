require 'sinatra'
require 'instagram'
require 'dotenv'
require 'open-uri'

Dotenv.load

enable :sessions

CALLBACK_URL = 'http://localhost:4567/oauth/callback'

Instagram.configure do |config|
  config.client_id = ENV['IG_CLIENT_ID']
  config.client_secret = ENV['IG_CLIENT_SECRET']
end

get '/' do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

get '/oauth/connect' do
  redirect Instagram.authorize_url(redirect_uri: CALLBACK_URL)
end

get '/oauth/callback' do
  response = Instagram.get_access_token(
    params[:code],
    redirect_uri: CALLBACK_URL
  )
  session[:access_token] = response.access_token
  redirect '/user_recent_media'
end

get '/user_recent_media' do
  begin
    client = Instagram.client(access_token: session[:access_token])
  rescue StandardError
    redirect Instagram.authorize_url(redirect_uri: CALLBACK_URL)
  end

  user = client.user
  image_url = client.user_recent_media.first.images.standard_resolution.url
  save_img image_url
  html = "<h1>#{user.username}'s last pic</h1>"
  html << "<img src='#{image_url}'>"
end

def save_img img
  File.open('img/ig.png', 'wb') do |fo|
    fo.write open(img).read
  end
end
