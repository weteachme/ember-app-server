#!/usr/bin/env ruby

require 'sinatra'

configure {
  set :server, :puma
}

class Pumatra < Sinatra::Base
  get '/*' do
    content_type 'text/html'
    version = params[:version] || ''
    version = ':' + version if version != ''
    File.read("../app/index.html#{version}")
  end

  run! if app_file == $0
end
