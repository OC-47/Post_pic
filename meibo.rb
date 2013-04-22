# coding:utf-8
require 'active_record'
require 'sinatra'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('development')


class Student < ActiveRecord::Base
end

get '/' do
	@students = Student.all
	erb :index
end


