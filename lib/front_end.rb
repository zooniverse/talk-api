class FrontEnd
  def self.host
    if Rails.env.production?
      'https://www.zooniverse.org'
    else
      'http://demo.zooniverse.org/panoptes-front-end'
    end
  end
  
  def self.zooniverse_talk
    "#{ host }/talk"
  end
  
  def self.project_talk(project)
    "#{ host }/projects/#{ project.slug }/talk"
  end
  
  def self.talk_root_for(object, project = nil)
    if project
      project_talk project
    elsif object.try(:project)
      project_talk object.project
    else
      zooniverse_talk
    end
  end
  
  def self.link_to(object, project = nil)
    case object
    when Board
      "#{ talk_root_for object, project }/#{ object.id }"
    when Comment
      "#{ talk_root_for object, project }/#{ object.discussion.board_id }/#{ object.discussion_id }?comment=#{ object.id }"
    when Conversation
      "#{ host }/inbox/#{ object.id }"
    when Discussion
      "#{ talk_root_for object, project }/#{ object.board_id }/#{ object.id }"
    when Moderation
      "#{ talk_root_for object, project }/moderations"
    when Project
      "#{ host }/projects/#{ object.slug }"
    when User
      "#{ host }/users/#{ object.login }"
    when UserConversation, Message
      "#{ host }/inbox/#{ object.conversation_id }"
    end
  end
end
