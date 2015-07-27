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
end
