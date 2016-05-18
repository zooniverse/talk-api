# Finds users with matching login or display name
# prioritized by
#   1. messaged users
#   2. mentioned users
#   3. available group mentions
#   4. all users
class UsernameCompletion
  def initialize(current_user, pattern, limit: 10)
    @current_user = current_user
    @pattern = pattern&.gsub /[^\w\d\-]/, ''
    @emptyPattern = @pattern.blank?
    @limit = limit
  end

  def results
    @search = sanitize @pattern
    @pattern = sanitize "#{ @pattern }%"
    connection.execute(query).to_a
  end

  def query
    <<-SQL
      select
        id,
        login,
        display_name

      from
        #{ unique_matching_users }

      order by
        priority desc,
        id asc

      limit #{ @limit }
    SQL
  end

  def unique_matching_users
    <<-SQL
      (
        select
          distinct on (id)
          id,
          login,
          display_name,
          priority

        from #{ matching_users }
      ) unique_matches
    SQL
  end

  def matching_users
    <<-SQL
      (
        #{ matching_mentions }

        union all

        #{ matching_messages }

        union all

        #{ matching_group_mentions }

        union all

        #{ all_matching_users }
      ) matches
    SQL
  end

  def matching_mentions
    <<-SQL
      (
        select
          users.id,
          users.login,
          users.display_name,
          3 priority

        from
          mentions, users

        where
          users.id = mentions.mentionable_id and
          mentions.user_id = #{ @current_user.id } and
          mentions.mentionable_type = 'User' and
          #{ users_match }

        group by
          mentions.mentionable_id,
          users.id,
          users.login,
          users.display_name

        order by
          count(users.id) desc

        limit
          #{ @limit }
      )
    SQL
  end

  def matching_messages
    <<-SQL
      (
        select
          users.id,
          users.login,
          users.display_name,
          2 priority

        from
          users

        where
          id in (
            select
              distinct(unnest(participant_ids))

            from
              conversations

            where
              participant_ids @> '{#{ @current_user.id }}'

            except
              select #{ @current_user.id }
        ) and
        #{ users_match }

        limit
          #{ @limit }
      )
    SQL
  end

  def matching_group_mentions
    <<-SQL
      (
        select
          group_mention_names.id,
          group_mention_names.login,
          group_mention_names.display_name,
          1 priority

        from
          #{ group_mention_names }

        where
          #{ users_match 'group_mention_names' }
      )
    SQL
  end

  def group_mention_names
    <<-SQL
      (
        select
          -1 id, 'admins' login, 'Administrators' display_name

        union all

        select
          -2 id, 'moderators' login, 'Moderators' display_name

        union all

        select
          -3 id, 'researchers' login, 'Researchers' display_name

        union all

        select
          -4 id, 'scientists' login, 'Scientists' display_name

        union all

        select
          -5 id, 'team' login, 'Team' display_name
      ) group_mention_names
    SQL
  end

  def all_matching_users
    return '(select null, null, null, null limit 0)' if @emptyPattern
    matched = PanoptesUser.connection.query <<-SQL
      (
        select
          users.id,
          users.login,
          users.display_name,
          0 priority

        from
          users

        where
          #{ users_match }

        order by
          similarity(users.login, #{ @search }) +
          similarity(users.display_name, #{ @search }) desc

        limit
          #{ @limit }
      )
    SQL

    matched.map do |row|
      id, login, display_name = row
      "(select #{ id }, #{ sanitize login }, #{ sanitize display_name }, 0)"
    end.join ' union all'
  end

  def users_match(table = 'users')
    return 'true' if @emptyPattern
    <<-SQL
      (
        lower(#{ table }.login::text) like #{ @pattern }::text or
        lower(#{ table }.display_name::text) like #{ @pattern }::text
      )
    SQL
  end

  def sanitize(string)
    connection.quote string
  end

  def connection
    ActiveRecord::Base.connection
  end
end
