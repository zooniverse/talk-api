class Comment
  module Mentioning
    extend ActiveSupport::Concern
    
    MATCH_MENTIONS = /
      (?:^|\s)            # match the beginning of the word
      ( \^([SC])(\d+) ) | # match mentioned focuses
      ( @([-\w\d]{3,}) )  # match mentioned users
    /imx
    
    included do
      before_save :parse_mentions
      before_update :parse_mentions, :update_mentions
    end
    
    def parse_mentions
      self.mentioning = { }
      body.scan(MATCH_MENTIONS).each do |focus_mention, focus_type, focus_id, user_mention, login|
        if focus_mention
          focus_klass = { 'S' => Subject, 'C' => Collection }[focus_type]
          mentioned focus_mention, focus_klass.find_by_id(focus_id)
        else
          mentioned user_mention, User.find_by_login(login)
        end
      end
    end
    
    def update_mentions
      removed_from(:mentioning).each_pair do |mention, hash|
        Mention.where(comment_id: id, mentionable_id: hash['id']).destroy_all
      end
    end
    
    protected
    
    def mentioned(mention, mentionable)
      return unless mentionable
      self.mentioning[mention] = { 'id' => mentionable.id, 'type' => mentionable.class.name }
      mentions.build(user: user, mentionable: mentionable) if added_to(:mentioning)[mention]
    end
  end
end
