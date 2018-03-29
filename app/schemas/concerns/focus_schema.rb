module FocusSchema
  extend ActiveSupport::Concern

  def focus(obj)
    obj.id :focus_id, null: true
    obj.entity :focus_type do
      enum %w(Subject)
    end
  end
end
