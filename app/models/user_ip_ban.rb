class UserIpBan < ApplicationRecord
  validates :ip, presence: true

  def self.banned?(request)
    where("ip >>= inet('#{ request.remote_ip }')").exists?
  end
end
