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
          .gsub(_boolean('and'), '\1&\2')               # replace all human terms with booleans
          .gsub(_boolean('or'), '\1|\2')
          .gsub(_boolean('not'), '\1!\2')
          .gsub(/(?<![\&\|\!])\s+(?![\&\|\!])/, ' & ')  # replace all spaces not preceded or followed with an AND boolean
          .gsub(/([\&\|])\s+[\&\|]/, '\1')              # replace invalid boolean combinations
          .gsub(/(\!\s+\&)|(\!\s+\|)|(\!\s+\!)/, '& !')
          .gsub(/^[\&\|\s+]+/, '')                      # replace invalid logic preceding terms
          .gsub(/(?<![\&\|])\s+\!/, ' & !')             # replace negations not preceded by an AND or an OR
      end
      
      def _boolean(term)
        /(^|\s+)#{ term }(\s+|$)/i
      end
    end
  end
end
