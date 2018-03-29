require 'factory_girl'
include FactoryGirl::Syntax::Methods

projects = create_list :project, 10

projects.each.with_index do |project, project_index|
  # =================================
  # = Setup a project with subjects =
  # =================================
  section = "project-#{ project.id }"
  subjects = create_list :subject, 50, project: project
  users = []

  # ====================
  # = Build some users =
  # ====================
  2.times{ users << create(:moderator, section: section) }
  2.times{ users << create(:admin, section: section) }
  2.times{ users << create(:scientist, section: section) }
  10.times{ users << create(:user) }

  # ======================
  # = Discussion helpers =
  # ======================
  random_tag = ->{
    (('a'..'d').to_a * 3).sample(1 + rand * 3).join
  }

  random_comment = ->{
    [
      "A comment",
      "A comment about ^S#{ subjects.sample.id }",
      "A comment tagging ##{ random_tag.call }"
    ].sample
  }

  random_focus = ->{
    rand < 0.3 ? subjects.sample : nil
  }

  # =====================
  # = Build discussions =
  # =====================
  print "#{ project_index + 1 } / #{ projects.length } "
  3.times do |board_index|
    board = create :board, section: section, title: "Board #{ board_index }"

    5.times do |discussion_index|
      discussion = create :discussion, board: board, user: users.sample, title: "Discussion #{ discussion_index } on #{ board.title }"

      25.times do |comment_index|
        create :comment, discussion: discussion, body: random_comment.call, user: users.sample, focus: random_focus.call
      end
      print '.'
    end
  end
  puts
end
