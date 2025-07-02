# frozen_string_literal: true

class VotableTagService < ApplicationService
  def build
    set_created_by_user_id
    super
  end

  private

  def set_created_by_user_id(&block)
    unauthorized! unless current_user
    begin
      if block_given?
        instance_eval(&block)
      else
        unrooted_params[:created_by_user_id] = current_user.id
      end
    rescue StandardError
      raise TalkService::ParameterError
    end
  end
end
