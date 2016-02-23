require 'digest'

class Comment
  module Publishing
    extend ActiveSupport::Concern
    
    included do
      after_commit :publish_to_event_stream_later, on: :create, if: :searchable?
    end
    
    def publish_to_event_stream_later
      CommentPublishWorker.perform_async id
    end
    
    def publish_to_event_stream
      ZooStream.publish event: 'comment', shard_by: discussion_id, data: to_event_stream
    end
    
    def to_event_stream
      {
        id: id,
        board_id: board_id,
        discussion_id: discussion_id,
        focus_id: focus_id,
        focus_type: focus_type,
        project_id: project_id,
        section: section,
        user_id: Digest::SHA1.hexdigest(user_id.to_s),
        user_ip: user_ip,
        created_at: created_at.as_json
      }
    end
  end
end
