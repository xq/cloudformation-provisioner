require 'json'
require 'aws-sdk-core'
require 'aws-sdk-resources'
require 'digest'

class StackBuilder
	
	attr_accessor :server_template, :client, :stack, :stack_name, :config, :credentials

	CREATION_WAIT_TIME = 5*60

	def load_settings(settings)
		@credentials = JSON.load(File.read(settings[:credentials_filename])) 
		@config = JSON.load(File.read(settings[:config_filename]), nil, symbolize_names: true)
	end

	def initialize(settings)
		load_settings(settings)
		@server_template = read_template(@config[:template_filename])
		Aws.config[:credentials] = Aws::Credentials.new(@credentials['access_key'], @credentials['secret_key'])
		Aws.config[:region] = @config[:region]
		@client = Aws::CloudFormation::Client.new
		@stack_name = "#{@config[:server_prefix]}-#{Digest::MD5.hexdigest(Time.now.to_s)}"
	end

	def build_stack
		stack_id = @client.create_stack({
			stack_name: @stack_name,
			template_body: @server_template,
			on_failure: "DELETE"
		}).stack_id
		stack_create_time = Time.now
		wait_for_stack_completion(stack_create_time)
		@stack = Aws::CloudFormation::Stack.new stack_id
		true
	end

	def wait_for_stack_completion(stack_create_time)
		@client.wait_until(:stack_create_complete, {stack_name: @stack_name}) do |w|
			w.max_attempts = nil
			w.before_wait do |attempts, response|
				puts "Creation status check.. Creation still in progress"
				if Time.now - stack_create_time > CREATION_WAIT_TIME
					throw :failure, "Stack creation taking too long"
				end
			end
		end
	end

	def delete_stack
		@client.delete_stack({ stack_name: @stack_name })
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

