module Sectioned
  extend ActiveSupport::Concern

  included do
    before_save :set_project_id
    belongs_to :project
  end

  def set_project_id
    self.project_id = section.match(/project-(\d+)/)[1].to_i
  rescue
    nil
  end
end
