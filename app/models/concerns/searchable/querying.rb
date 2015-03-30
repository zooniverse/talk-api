module Searchable
  module Querying
    extend ActiveSupport::Concern
    
    module ClassMethods
      def search(terms)
        searchable_klass.with_content _parse_query(terms)
      end
      
      def _parse_query(terms)
        terms
          .gsub(/([\&\|\!])(?!\s)/, '\1 ')              # replace all unspaced booleans
          .gsub(/and/i, '&')                            # replace all human terms with booleans
          .gsub(/or/i, '|')
          .gsub(/not/i, '!')
          .gsub(/(?<![\&\|\!])\s+(?![\&\|\!])/, ' & ')  # replace all spaces not preceded or followed with an AND boolean
          .gsub(/([\&\|])\s+[\&\|]/, '\1')              # replace invalid boolean combinations
          .gsub(/(\!\s+\&)|(\!\s+\|)|(\!\s+\!)/, '& !')
          .gsub(/^[\&\|\s+]+/, '')                      # replace invalid logic preceding terms
          .gsub(/(?<![\&\|])\s+\!/, ' & !')             # replace negations not preceded by an AND or an OR
      end
    end
  end
end
