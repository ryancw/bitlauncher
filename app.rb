gem 'aws-sdk', '~> 2'

require 'sinatra'
require 'aws-sdk'
require 'securerandom'
require 'json'

TEMPLATE = IO.binread('wordpress.template')

set :haml, format: :html5

get '/' do
  haml :index
end

post '/create' do
  content_type :json
  stack_params = create_instance(params['access'], params['secret'])
  if stack_params.has_key? :error
    halt 401, 'Not Authorized'
  else
    stack_params.to_json
  end
end

get '/status' do
  content_type :json
  status = get_status(params['access'], params['secret'], params['stack_name'])
  {status: status}.to_json
end

def create_instance(access_key, secret_key)
  stack_name = "bitlauncher" + SecureRandom.hex(8)

  begin
    cloudformation = cloud_client(access_key, secret_key)
    cloudformation.create_stack(
      stack_name: stack_name,
      template_body: TEMPLATE
    )

    return {stack_name: stack_name}
  rescue Aws::CloudFormation::Errors::ServiceError => e
    return {error: e}
  end
end

def get_status(access_key, secret_key, stack_name)
  begin
    cloudformation = cloud_client(access_key, secret_key)
    cloudformation.describe_stacks(stack_name: stack_name)[:stacks][0][:stack_status]
  rescue Aws::CloudFormation::Errors::ServiceError => e
    p e
  end
end

def cloud_client(access_key, secret_key)
  Aws::CloudFormation::Client.new(
      region: 'us-east-1',
      access_key_id: access_key,
      secret_access_key: secret_key
  )
end


