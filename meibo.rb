# coding:utf-8
require 'active_record'
require 'sinatra'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection('development')


class Student < ActiveRecord::Base
end

get '/' do
  "Hello World"
end


# idが「1234567890」の学生だけ抽出しオブジェクトに格納します．
#student = Student.find('1234567890')
#puts student.id
#puts student.name
students = Student.all
students.each do |stu|
  puts stu.id + "\t" + stu.name + "\t" + stu.email
end
