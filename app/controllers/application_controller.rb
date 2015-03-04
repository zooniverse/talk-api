class ApplicationController < ActionController::Base
  include Pundit
  include ActionRendering
  include ActionRescuing
  
  def root
    authorize :application, :index?
    render json: {
      boards: { href: '/boards', type: 'boards' },
      comments: { href: '/comments', type: 'comments' },
      collections: { href: '/collections', type: 'collections' },
      conversations: { href: '/conversations', type: 'conversations' },
      discussions: { href: '/discussions', type: 'discussions' },
      messages: { href: '/messages', type: 'messages' },
      moderations: { href: '/moderations', type: 'moderations' },
      subjects: { href: '/subjects', type: 'subjects' },
      tags: { href: '/tags', type: 'tags' },
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
  end
end
