class ActionDispatch::TestResponse
  def json
    @_json ||= JSON.parse(body).with_indifferent_access
  end
end
