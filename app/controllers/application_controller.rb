class ApplicationController < ActionController::Base
  include Pundit
  include ActionRendering
  include ActionRescuing
  
  before_action :set_format
  before_action :enforce_ban, if: ->{ current_user }
  before_action :enforce_ip_ban
  
  def root
    authorize :application, :index?
    respond_to do |format|
      format.html{ redirect_to FrontEnd.zooniverse_talk }
      format.json{ render json: resources }
    end
  end
  
  def resources
    {
      announcements: { href: '/announcements', type: 'announcements' },
      blocked_users: { href: '/blocked_users', type: 'blocked_users' },
      boards: { href: '/boards', type: 'boards' },
      comments: { href: '/comments', type: 'comments' },
      conversations: { href: '/conversations', type: 'conversations' },
      data_requests: { href: '/data_requests', type: 'data_requests' },
      discussions: { href: '/discussions', type: 'discussions' },
      messages: { href: '/messages', type: 'messages' },
      moderations: { href: '/moderations', type: 'moderations' },
      notifications: { href: '/notifications', type: 'notifications' },
      roles: { href: '/roles', type: 'roles' },
      subscription_preferences: { href: '/subscription_preferences', type: 'subscription_preferences' },
      subscriptions: { href: '/subscriptions', type: 'subscriptions' },
      tags: { href: '/tags', type: 'tags' },
      popular_tags: { href: '/tags/popular', type: 'popular_tags' },
      user_ip_bans: { href: '/user_ip_bans', type: 'user_ip_bans' },
      users: { href: '/users', type: 'users' }
    }
  end
  
  def set_format
    request.format = :json if request.format == :json_api
  end
  
  def sinkhole
    raise ActionController::RoutingError.new 'Not found'
  end
  
  def log_event!(label, payload)
    EventLog.create label: label, user_id: current_user.try(:id), payload: payload
  rescue
    nil
  end
  
  concerning :Authentication do
    def bearer_token
      return @bearer_token if @bearer_token
      auth = request.headers.fetch 'Authorization', ''
      _, @bearer_token = *auth.match(/^Bearer (\w+)$/i)
      @bearer_token
    end
  end
  
  concerning :CurrentUser do
    def current_user
      return unless bearer_token
      @current_user ||= User.from_panoptes bearer_token
    end
    
    def current_user_ip
      request.remote_ip
    end
    
    def enforce_ban
      raise Talk::BannedUserError if current_user.banned?
    end
    
    def enforce_ip_ban
      raise Talk::BannedUserError if UserIpBan.banned?(request)
    end
  end
end
