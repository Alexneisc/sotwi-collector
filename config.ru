# require 'sinatra'
# require 'twitter'
# require 'sinatra/activerecord'
#
# project_root = File.dirname(File.absolute_path(__FILE__))
# Dir.glob(project_root + '/models/*.rb').each{|f| require f}

require './app'

run Sinatra::Application
