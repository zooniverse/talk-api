class FrontEnd
  def self.host
    if Rails.env.production?
      'https://www.zooniverse.org'
    else
      'http://demo.zooniverse.org/panoptes-front-end'
    end
  end
  
  def self.zooniverse_talk
    "#{ host }/#/talk"
  end
  
  def self.project_talk(project)
    "#{ host }/#/projects/#{ project.slug }/talk"
  end
  
  def self.talk_root_for(object)
    if object.try(:project)
      project_talk object.project
    else
      zooniverse_talk
    end
  end
  
  def self.link_to(object)
    case object
    when Board
      "#{ talk_root_for object }/#{ object.id }"
    when Comment
      "#{ talk_root_for object }/#{ object.discussion.board_id }/#{ object.discussion_id }?comment=#{ object.id }"
    when Discussion
      "#{ talk_root_for object }/#{ object.board_id }/#{ object.id }"
    when Project
      "#{ host }/#/projects/#{ object.slug }"
    when User
      "#{ host }/#/users/#{ object.login }"
    when UserConversation
      "#{ host }/#/inbox/#{ object.conversation_id }"
    end
  end
end
