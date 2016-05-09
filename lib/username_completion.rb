# Finds users with matching login or display name
# prioritized by
#   1. messaged users
#   2. mentioned users
#   3. available group mentions
#   4. all users
class UsernameCompletion
  def initialize(current_user, pattern, limit: 10)
    @current_user = current_user
    @pattern = pattern&.gsub '%', ''
    @limit = limit
  end

  def results
    return [] unless @pattern.present?
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
        (
          select
            distinct on (id)
            id,
            login,
            display_name,
            priority

          from (
            -- Messages
            (
              select
                distinct on (users.id)
                users.id,
                users.login,
                users.display_name,
                3 priority

              from
                users

              where
                id in (
                  select
                    unnest(participant_ids)

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

            union

            -- Mentions
            (
              select
                users.id,
                users.login,
                users.display_name,
                2 priority

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

            union

            -- Group mentions
            (
              select
                group_mention_names.id,
                group_mention_names.login,
                group_mention_names.display_name,
                1 priority

              from
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

              where
                #{ users_match 'group_mention_names' }
            )

            union

            -- All users
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

              limit
                #{ @limit }
            )
          ) matches
        ) unique_matches

      order by
        priority desc,
        id asc

      limit #{ @limit }
    SQL
  end

  def users_match(table = 'users')
    <<-SQL
      (
        lower(#{ table }.login) like #{ @pattern } or
        lower(#{ table }.display_name) like #{ @pattern }
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
