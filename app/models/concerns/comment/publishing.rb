require 'kafka'
require 'digest'

class Comment
  module Publishing
    extend ActiveSupport::Concern
    
    included do
      after_commit :publish_to_kafka_later, on: :create
    end
    
    def publish_to_kafka_later
      CommentPublishWorker.perform_async id
    end
    
    def publish_to_kafka
      Kafka.publish 'events', to_kafka, kafka_id
    end
    
    def kafka_id
      "comment.#{ id }"
    end
    
    def kafka_data
      attributes.slice(*%w(
        board_id
        discussion_id
        focus_id
        focus_type
        project_id
        section
      )).symbolize_keys
    end
    
    def to_kafka
      {
        event_id: kafka_id,
        event_time: created_at.as_json,
        event_type: 'talk.comment',
        user_id: Digest::SHA1.hexdigest(user_id.to_s),
        _ip_address: user_ip,
      }.merge kafka_data
    end
  end
end
