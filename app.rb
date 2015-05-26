require 'sinatra'
require 'aws-sdk'
require 'securerandom'
require 'json'
require 'haml'

TEMPLATE = IO.binread('wordpress.template')

set :haml, format: :html5

get '/' do
  haml :index
end

post '/create' do
  content_type :json
  stack_params = create_instance(params['access'], params['secret'])
  if stack_params.has_key? :error
    {error: 'Failed to create instance'}.to_json
  else
    stack_params.to_json
  end
end

get '/status' do
  content_type :json
  status = get_status(params['access'], params['secret'], params['stack_name'])
  status.to_json
end

post '/stop' do
  content_type :json
  status = stop_instance(params['access'], params['secret'], params['stack_name'])
  status.to_json
end

def create_instance(access_key, secret_key)
  stack_name = "bitlauncher" + SecureRandom.hex(8)

  begin
    cf = cloud_client(access_key, secret_key)
    cf.create_stack(
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
    cf = cloud_client(access_key, secret_key)
    stack = cf.describe_stacks(stack_name: stack_name)[:stacks][0]
    status = {status: stack[:stack_status]}
    status[:url] = stack.outputs[0][:output_value] if status[:status] == 'CREATE_COMPLETE'

    status
  rescue Aws::CloudFormation::Errors::ServiceError => e
    p e
  end
end

def stop_instance(access_key, secret_key, stack_name)
  id = instance_id(cloud_client(access_key, secret_key), stack_name)
  ec = ec2_client(access_key, secret_key)
  ec.stop_instances(instance_ids: [id])
end

def instance_id(client, stack_name)
  client.list_stack_resources(stack_name: stack_name)[0][2][:physical_resource_id]
end

def ec2_client(access_key, secret_key)
  Aws::EC2::Client.new(
    region: 'us-east-1',
    access_key_id: access_key,
    secret_access_key: secret_key
  )
end

def cloud_client(access_key, secret_key)
  Aws::CloudFormation::Client.new(
      region: 'us-east-1',
      access_key_id: access_key,
      secret_access_key: secret_key
  )
end
