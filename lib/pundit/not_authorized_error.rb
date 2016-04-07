require 'pundit'

module Pundit
  class NotAuthorizedError < Error
    def initialize(options = { })
      message = if options.is_a?(String)
        options
      else
        @query = options[:query]
        @record = options[:record]
        @policy = options[:policy]
        options.fetch(:message) { "not allowed to #{ query.sub /\?$/, '' } this #{ name_of record }" }
      end

      super message
    end

    def name_of(record)
      case record
      when ActiveRecord::Relation
        record.klass.name
      else ActiveRecord::Base
        record.model_name.name
      end
    rescue
      ''
    end
  end
end
