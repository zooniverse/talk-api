module Sectioned
  extend ActiveSupport::Concern

  included do
    before_save :set_project_id
    belongs_to :project
  end

  def set_project_id
    self.project_id = project_section_match[1].to_i
  rescue
    nil
  end

  private

  def project_section_match
    section.match(/project-(\d+)/)
  end
end
