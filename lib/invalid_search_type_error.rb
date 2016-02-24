class InvalidSearchTypeError < StandardError
  def initialize(name_error)
    type = name_error.match(/uninitialized constant (\w+)/)[1] rescue nil
    message = if type
      "#{ type } is not a valid search type"
    else
      "The property #/types contains an invalid search type"
    end

    super message
  end
end
