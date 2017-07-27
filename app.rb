require 'dotenv/load'
require 'sinatra'
require 'sendgrid-ruby'

include SendGrid

HTTP_SUCCESS_CODES = ['200', '201', '202']

set :protection, except: :frame_options

get '/' do
  erb :index
end

get '/contact_us' do
  erb :contact_us
end

post '/contact_us' do
  from = Email.new(email: params[:email])
  subject = 'Presupuestación desde la web'
  to = Email.new(email: 'uruguay.security@mailinator.com')

  locals_for_mailer = {
    name: params[:name],
    email: params[:email],
    phone: params[:phone],
    comment: params[:comment],
    purpose: params[:purpose]
  }

  content = Content.new(type: 'text/html', value: erb(:mailer, locals: locals_for_mailer, layout: false))
  mail = Mail.new(from, subject, to, content)

  sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  response = sg.client.mail._('send').post(request_body: mail.to_json)

  if HTTP_SUCCESS_CODES.include? response.status_code
    redirect '/contact_us'
  else
    redirect '/error'
  end
end

get '/error' do
  erb :error
end
