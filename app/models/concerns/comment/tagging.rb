class Comment
  module Tagging
    extend ActiveSupport::Concern

    MATCH_TAGS = /
      (?:^|[^\w])         # match the beginning of the word
      (\#([-\w\d]{3,40})) # match tags
    /imx

    included do
      before_save :parse_tags
      before_update :parse_tags, :update_tags
    end

    def parse_tags
      self.tagging = { }
      body.scan(MATCH_TAGS).each do |tag, name|
        tagged tag.downcase, name.downcase
      end
    end

    def update_tags
      removed_from(:tagging).each_pair do |tag, name|
        Tag.where(comment_id: id, name: name).destroy_all
      end
    end

    protected

    def tagged(tag, name)
      return if tagging[tag]
      self.tagging[tag] = name
      tags.build(name: name) if added_to(:tagging)[tag]
    end
  end
end
