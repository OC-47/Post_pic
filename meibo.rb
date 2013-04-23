# coding:utf-8

require 'rubygems'
require 'active_record'
require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'pp'
require 'twitter_oauth'






# sessionsをtrueに
set :sessions, true


# 起動時に1回だけ実行される
configure do
	use Rack::Session::Cookie, :secret => Digest::SHA1.hexdigest(rand.to_s)
	KEY = "kj9TRCnVMak8BRpYv1iO2Q"
	SECRET = "8pUiRSKRUT1tIfYSORSYp2Bki9F9aWURcwGJ76a6Vk"
end


# TwitterOAuth::ClientっていうDBに新たに。
before do
	@twitter = TwitterOAuth::Client.new(
		:consumer_key => KEY,
		:consumer_secret => SECRET,
		:token => session[:access_token],
		:secret => session[:secret_token]
	)
end


# base_url関数を定義
def base_url
	default_port = (request.scheme == "http") ? 80 : 443
	port = (request.port == default_port) ? "" : ":#{request.port.to_s}"
	return "#{request.scheme}://#{request.host}#{port}"
end



get '/' do
	if session[:login]
		@screen_name = @twitter.info['screen_name']
		@image_url = @twitter.info['profile_image_url_https']
		erb :login, :layout => false
	else
		erb :notlogin, :layout => false
	end
end


get '/login' do
	#callback_url = "#{base_url}/access_token"
	callback_url = "#{base_url}/access_token"
	request_token = @twitter.request_token(
		:oauth_callback => callback_url
	)
	session[:request_token] = request_token.token
	session[:request_token_secret] = request_token.secret
	redirect request_token.authorize_url.gsub('authorize', 'authenticate')
end

get '/access_token' do
	begin
		@access_token = @twitter.authorize(
			session[:request_token],
			session[:request_token_secret],
			:oauth_verifier => params[:oauth_verifier]
		)
	rescue OAuth::Unauthorized
	end

	if @twitter.authorized?
		session[:access_token] = @access_token.token
		session[:secret_token] = @access_token.secret
		session[:login] = true
		redirect '/'
	else
		erb :error, :layout => false
	end 
end

get '/logout' do
	@twitter=nil
	session.clear
	redirect '/'
end




ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('development')

class Student < ActiveRecord::Base
end



get '/tatsuki' do
  @students = Student.all
  erb :index
end



post '/new' do
if params[:file]
  student = Student.new
  student.nan = params[:nan]
puts "ここからさきにidが入るよ"
puts params[:nan]

  student.name = "#{params[:file][:filename]}"
  student.save


		save_path = "./public/images/#{params[:file][:filename]}"

		File.open(save_path, 'wb') do |f|
			p params[:file][:tempfile]
			f.write params[:file][:tempfile].read
		end
	end

  redirect '/'
end



delete '/del' do
 
puts "ここからさきにidが入るよ"
puts params[:name]
student = Student.find_by_name(params[:name])
student.destroy
  redirect '/'
end


register Sinatra::Reloader
