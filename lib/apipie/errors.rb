module Apipie

  class Error < StandardError
  end

  class ParamError < Error
  end

  class UnknownCode < Error
  end

  class ReturnsMultipleDefinitionError < Error
    def to_s
      "a 'returns' statement cannot indicate both array_of and type"
    end
  end

  # abstract
  class DefinedParamError < ParamError
    attr_accessor :param

    def initialize(param)
      @param = param
    end
  end

  class ParamMultipleMissing < ParamError
    attr_accessor :params

    def initialize(params)
      @params = params
    end

    def to_s
      params.map do |param|
        ParamMissing.new(param).to_s
      end.join("\n")
    end
  end

  class ParamMissing < DefinedParamError
    def to_s
      unless @param.options[:missing_message].nil?
        if @param.options[:missing_message].kind_of?(Proc)
          @param.options[:missing_message].call
        else
          @param.options[:missing_message].to_s
        end
      else
        "Missing parameter #{@param.name}"
      end
    end
  end

  class UnknownParam < DefinedParamError
    def to_s
      "Unknown parameter #{@param}"
    end
  end

  class ParamInvalid < DefinedParamError
    attr_accessor :value, :error

    def initialize(param, value, error)
      super param
      @value = value
      @error = error
    end

    def to_s
      "Invalid parameter '#{@param}' value #{@value.inspect}: #{@error}"
    end
  end

  class ResponseDoesNotMatchSwaggerSchema < Error
    def initialize(controller_name, method_name, response_code, error_messages, schema, returned_object)
      super("Response does not match swagger schema (#{controller_name}##{method_name} #{response_code}): #{error_messages}\nSchema: #{JSON(schema)}\nReturned object: #{returned_object}")
    end
  end

  class NoDocumentedMethod < Error
    def initialize(controller_name, method_name)
      super("There is no documented method #{controller_name}##{method_name}")
    end
  end
end
