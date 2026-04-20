#!/usr/bin/env ruby

require 'sinatra'

configure {
  set :server, :puma
}

class Pumatra < Sinatra::Base
  get '/up' do
    status 200
    body 'OK'
  end

  get '/*' do
    content_type 'text/html'
    version = params[:version] || ''
    version = ':' + version if version != ''
    path = "/ember-app/index.html#{version}"
    halt 503, 'App not ready — index.html not found' unless File.exist?(path)
    File.read(path)
  end

  run! if app_file == $0
end
