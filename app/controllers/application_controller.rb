class ApplicationController < ActionController::Base
  include Pundit
  include ActionRendering
  include ActionRescuing
  
  before_action :enforce_ban, if: ->{ current_user }
  before_action :enforce_ip_ban
  
  def root
    authorize :application, :index?
    render json: {
      announcements: { href: '/announcements', type: 'announcements' },
      boards: { href: '/boards', type: 'boards' },
      comments: { href: '/comments', type: 'comments' },
      collections: { href: '/collections', type: 'collections' },
      conversations: { href: '/conversations', type: 'conversations' },
      discussions: { href: '/discussions', type: 'discussions' },
      messages: { href: '/messages', type: 'messages' },
      moderations: { href: '/moderations', type: 'moderations' },
      notifications: { href: '/notifications', type: 'notifications' },
      roles: { href: '/roles', type: 'roles' },
      subjects: { href: '/subjects', type: 'subjects' },
      tags: { href: '/tags', type: 'tags' },
      user_ip_bans: { href: '/user_ip_bans', type: 'user_ip_bans' },
      users: { href: '/users', type: 'users' }
    }
  end
  
  def sinkhole
    raise ActionController::RoutingError.new 'Not found'
  end
  
  concerning :Authentication do
    def bearer_token
      return @bearer_token if @bearer_token
      auth = request.headers.fetch 'Authorization', ''
      _, @bearer_token = *auth.match(/^Bearer (\w+)$/i)
      @bearer_token
    end
    
    def panoptes
      @panoptes ||= PanoptesProxy.new bearer_token
    end
  end
  
  concerning :CurrentUser do
    def current_user
      return unless bearer_token
      @current_user ||= User.from_panoptes panoptes.get 'me'
    end
    
    def enforce_ban
      raise Talk::BannedUserError if current_user.banned?
    end
    
    def enforce_ip_ban
      raise Talk::BannedUserError if UserIpBan.banned?(request)
    end
  end
end
