module Searchable
  module Querying
    extend ActiveSupport::Concern
    
    module ClassMethods
      def search(terms)
        searchable_klass.with_content _parse_query(terms)
      end
      
      def _parse_query(terms)
        terms[0..1000]
          .gsub(/\s+/m, ' ')                                            # replace all forms of whitespace with spaces
          .gsub(/[^ \-[:word:]\&\|\!]/u, '')                            # remove all invalid characters
          .gsub(/([\&\|\!])(?!\s)/, '\1 ')                              # replace all unspaced booleans
          .strip                                                        # remove all leading and trailing whitespace
          .gsub(_boolean('and'), '\1&\2')                               # replace all human terms with booleans
          .gsub(_boolean('or'), '\1|\2')
          .gsub(_boolean('not'), '\1!\2')
          .gsub(/(?<![\&\|\!])\s+(?![\&\|\!])/, ' & ')                  # replace all spaces not preceded or followed with an AND boolean
          .gsub(/(([\&\|]\s+)+)/, '\2')                                 # replace invalid boolean combinations
          .gsub(/(\!\s+\&)|(\!\s+\|)|(\!\s+\!)/, '& !')
          .gsub(/^[\&\|\s+]+/, '')                                      # remove invalid logic preceding terms
          .gsub(/[\&\|\!\s]+$/, '')                                     # remove invalid logic succeeding terms
          .gsub(/(?<![\&\|])\s+\!/, ' & !')                             # replace negations not preceded by an AND or an OR
          .gsub(/((\&\s+){2,})|((\|\s+){2,})|((\!\s+){2,})/, '\2\4\6')  # replace repetitious booleans
      end
      
      def _boolean(term)
        /(^|\s+)#{ term }(\s+|$)/i
      end
    end
  end
end
