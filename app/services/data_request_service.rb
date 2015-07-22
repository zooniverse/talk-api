class DataRequestService < ApplicationService
  def build
    set_user
    super
  end
end
