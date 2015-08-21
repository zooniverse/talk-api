module MailerHelper
  def h1(content = nil, &block)
    content ||= capture &block
    "<h1 style=\"font-size: 30px; font-weight: 700; line-height: 45px;\">#{ content }</h1>".html_safe
  end
  
  def h2(content = nil, &block)
    content ||= capture &block
    "<h2 style=\"font-size: 22px; font-weight: 700; color: #4F4F4F; line-height: 33px;\">#{ content }</h2>".html_safe
  end
  
  def h3(content = nil, &block)
    content ||= capture &block
    "<h3 style=\"font-size: 18px; font-weight: 700; color: #4F4F4F; line-height: 26px;\">#{ content }</h3>".html_safe
  end
  
  def container(content = nil, &block)
    content ||= capture &block
    "<div style=\"margin: 5px auto; background: #F1F1F1; border-radius: 6px; border: 2px solid #E1E1E1; padding: 5px;\">#{ content }</div>".html_safe
  end
  
  def link_style
    'color: #0072FF; text-decoration: none;'
  end
end
