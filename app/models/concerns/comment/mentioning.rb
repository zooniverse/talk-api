class Comment
  module Mentioning
    extend ActiveSupport::Concern
    
    MATCH_MENTIONS = /
      (?:^|\s)            # match the beginning of the word
      ( \^([SC])(\d+) ) | # match mentioned focuses
      ( @(                # match group mentions
          admins |
          moderators |
          researchers |
          scientists |
          team
        )
      ) |
      ( @([-\w\d]+) )     # match mentioned users
    /imx
    
    included do
      before_save :parse_mentions
      before_update :parse_mentions, :update_mentions, :update_group_mentions
    end
    
    def parse_mentions
      self.mentioning = { }
      self.group_mentioning = { }
      body.scan(MATCH_MENTIONS).each do |focus_mention, focus_type, focus_id, group_mention, group_name, user_mention, login|
        if focus_mention
          focus_klass = { 'S' => Subject, 'C' => Collection }[focus_type]
          next unless focus_klass.present? && focus_id.present?
          mentioned focus_mention, focus_klass.find_by_id(focus_id)
        elsif group_mention
          group_mentioned group_name
        elsif user_mention
          mentioned_user = User.find_by_login login
          mentioned(user_mention, mentioned_user) if accessible_by?(mentioned_user)
        end
      end
    end
    
    def update_mentions
      removed_from(:mentioning).each_pair do |mention, hash|
        Mention.where(comment_id: id, mentionable_id: hash['id']).destroy_all
      end
    end
    
    def update_group_mentions
      removed_from(:group_mentioning).each_pair do |group_name, hash|
        GroupMention.where(comment_id: id, name: group_name).destroy_all
      end
    end
    
    def accessible_by?(user)
      return false unless user
      CommentPolicy.new(user, self).show?
    end
    
    protected
    
    def mentioned(mention, mentionable)
      return unless mentionable
      return if mentioning[mention]
      self.mentioning[mention] = { 'id' => mentionable.id, 'type' => mentionable.class.name }
      mentions.build(user: user, mentionable: mentionable) if added_to(:mentioning)[mention]
    end
    
    def group_mentioned(name)
      return if group_mentioning[name]
      self.group_mentioning[name] = "@#{ name }"
      group_mentions.build(name: name) if added_to(:group_mentioning)[name]
    end
  end
end
