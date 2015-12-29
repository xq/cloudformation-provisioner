require 'json'
require 'aws-sdk-core'
require 'aws-sdk-resources'
require 'digest'

class StackBuilder
	
	attr_accessor :server_template, :client, :stack, :stack_name

	CONFIG = JSON.load(File.read('configuration.json'), nil, symbolize_names: true)
	CREDENTIALS = JSON.load(File.read('credentials.json'))
	CREATION_WAIT_TIME = 5*60

	def initialize(template_filename)
		Aws.config[:credentials] = Aws::Credentials.new(CREDENTIALS['access_key'], CREDENTIALS['secret_key'])
		Aws.config[:region] = CONFIG[:region]
		@server_template = read_template(template_filename)
		@client = Aws::CloudFormation::Client.new
		@stack_name = "webserver-" + Digest::MD5.hexdigest(Time.now.to_s)
	end

	def build_stack
		stack_id = @client.create_stack({
			stack_name: @stack_name,
			template_body: @server_template,
			on_failure: "DELETE"
		}).stack_id
		stack_create_time = Time.now
		stack_result = @client.wait_until(:stack_create_complete, {stack_name: @stack_name}) do |w|
			w.max_attempts = nil
			w.before_wait do |attempts, response|
				puts "Creation status check.. Creation still in progress"
				if Time.now - stack_create_time > CREATION_WAIT_TIME
					throw :failure, "Stack creation taking too long"
				end
			end
		end
		@stack = Aws::CloudFormation::Stack.new stack_id
	end

	def print_stack_output
		@stack.outputs[0].output_value
	end

	def read_template(filename)
		file = File.open(filename, "rb")
		contents = file.read
		file.close
		contents
	end

end

