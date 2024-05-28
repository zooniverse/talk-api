# TODO: Can Remove Lines 2-6 once on Rails 5
class ActionController::TestResponse
  def json
    @_json ||= JSON.parse(body).with_indifferent_access
  end
end

# On Rails 5, Test responses do not inherit from ctionController::TestResponse

class ActionDispatch::TestResponse
  def json
    @_json ||= JSON.parse(body).with_indifferent_access
  end
end
