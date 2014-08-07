#############To do: Revise Base Class ##################

class ScriptHandler
	include ActiveModel::Validations
	validate :required_arguments_cannot_be_blank, :arguments_input_should_be_positive, :arguments_input_should_be_numerical
	def initialize(script_name,required_argument_hash = {}, optional_argument_hash = {})
		@script_name = script_name
		@required_argument_hash = required_argument_hash
		@optional_argument_hash = optional_argument_hash
		@argument_list = ""
	end
	
	# def set_input(input_file_name)
	# 	@input_file_name = input_file_name
	# end
	# def set_output(output_file_name)
	# 	@output_file_name = output_file_name
	# end
	
	def run_with_option(input_file_name,output_file_name, optional_argument = nil)
		argument_list += @required_argument_hash.map{|k,v| "-#{k} #{v}"}.join(' ')
		#throw when optional argument input is blank
		# optional_argument.each{|option| argument_list += " -#{option} #{optional_argument_hash[option]} "}
		"python #{@script_name} #{argument_list} #{optional_argument} < #{input_file_name} > #{output_file_name}"
	end

	protected 

	def required_arguments_cannot_be_blank
		@required_argument_hash.each do |k, v|
			if v.nil?
				errors.add(:base, "argument #{k} input cannot be blank")
				return false
			end
		end
	end

	def arguments_input_should_be_positive
		@required_argument_hash.each do |k, v|
			if v <= 0
				errors.add(:base, "argument #{k} input should be positive")
				return false
			end
		end
	end

	def arguments_input_should_be_numerical
		@required_argument_hash.each do |k, v|			
		    errors.add(:base, "argument #{k} should be a number") and return false unless v.to_f.is_a? Numeric			
		end
	end

	def prepare_input(game)
	end
end