#!/usr/bin/env ruby

require 'sinatra'
require 'aws-sdk-s3'

configure {
  set :server, :puma
}

class Pumatra < Sinatra::Base
  S3_BUCKET = ENV.fetch('S3_BUCKET')
  S3_KEY = ENV.fetch('S3_KEY', 'wtm-dashboard-app
/staging/index.html')
  S3_REGION = ENV.fetch('AWS_REGION', 'ap-southeast-2')
  SECRET_KEY = ENV.fetch('SECRET_KEY')
  S3_CLIENT = Aws::S3::Client.new(region: S3_REGION)

  @@html = nil
  @@history = []
  @@mutex = Mutex.new

  helpers do
    def authenticate!
      provided = params[:secret_key] || env['HTTP_X_SECRET_KEY']
      halt 401, 'Unauthorized' unless provided == SECRET_KEY
    end

    def fetch_from_s3
      resp = S3_CLIENT.get_object(bucket: S3_BUCKET, key: S3_KEY)
      resp.body.read
    end
  end

  get '/up' do
    status 200
    body 'OK'
  end

  post '/cache/clear' do
    authenticate!

    @@mutex.synchronize do
      if @@html
        @@history.push(@@html)
        @@history.shift if @@history.length > 5
      end
      @@html = nil
    end

    content_type :json
    { status: 'cleared', step: @@history.length }.to_json
  end

  post '/rollback' do
    authenticate!
    step = (params[:step] || 1).to_i
    halt 400, "Invalid step" if step < 1

    @@mutex.synchronize do
      halt 400, "Only #{@@history.length} steps available" if step > @@history.length
      (step - 1).times { @@history.pop }
      @@html = @@history.pop
    end

    content_type :json
    { status: 'rolled back', step: step, steps_remaining: @@history.length }.to_json
  end

  get '/*' do
    content_type 'text/html'

    html = @@mutex.synchronize { @@html }
    unless html
      begin
        html = fetch_from_s3
        @@mutex.synchronize { @@html = html }
      rescue Aws::S3::Errors::NoSuchKey
        halt 503, 'App not ready — index.html not found in S3'
      end
    end

    html
  end

  run! if app_file == $0
end
