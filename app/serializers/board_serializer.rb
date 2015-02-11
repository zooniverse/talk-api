class BoardSerializer
  include TalkSerializer
  all_attributes except: :permissions
  can_include :discussions, :parent, :sub_boards
end
