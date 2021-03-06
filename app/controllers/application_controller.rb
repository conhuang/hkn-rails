class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_current_user, :merge_messages, :check_authorizations, :set_view_variables
  layout 'application'

  attr_reader :current_user, :real_current_user

  def ssl_required?
    return Rails::Configuration::SSL if defined? Rails::Configuration::SSL
    return false if request.remote_ip.eql?('127.0.0.1') || ['development','test'].include?(Rails.env)
    super
  end

  #This is a bit of dynamic code that allows you to use methods like
  #authorize_foo to call authorize with a group as an argument. It might be
  #good to clean it up a little and put the matching in a separate class.
  # The idea comes from rails' dynamic finders.
  def respond_to?(method_id, include_private = false)
    case method_id.to_s
      when /\Aauthorize_([_a-zA-Z]\w*)\z/
        return true
      else
        super
    end
  end

  def method_missing(method_id, *arguments, &block)
    case method_id.to_s
      when /\Aauthorize_([_a-zA-Z]\w*)\z/
        group = $1
        self.send :authorize, group
      else
        super
    end
  end

  def current_user_session
    @current_user_session ||= UserSession.find
  end

  def current_user=(user)
    @current_user = user
  end

  def auth=(auth)
    @auth = auth
  end

  def render_404
    raise ActionController::RoutingError.new('Not Found')
  end

  def test_exception_notification
    raise 'This is a test. This is only a test.'
  end

  def authorize(group_or_groups=nil)
    # group_or_groups must be either a single Group name or an array of Group names
    # If user is in any of the groups, then s/he has access
    # If group_or_groups is not specified (called authorize with no arguments), then should return true if the person is logged in, false otherwise.
    if @current_user.nil?
      redirect_to :login, notice: "Please log in to access this page.", flash: {referer: request.fullpath}
      return false
    end
    return true if group_or_groups.nil?
    groups = ([String, Symbol].include? group_or_groups.class) ? [group_or_groups] : group_or_groups
    groups = groups.map(&:to_s) | ["superusers"]
    if (groups & @current_user.groups.collect(&:name)).blank?
      redirect_to :root, notice: "Insufficient privileges to access this page."
      return false
    end
    true
  end

  #-----------------------------------------------------------------------
  # Private Methods
  #-----------------------------------------------------------------------
  private

  def get_current_user
    # Just return that this is a bad request if a null byte is given in a
    # cookie. The Berkeley security scanner particularly likes doing this
    # because it gets 500 errors that it thinks might give something useful, so
    # give it a 4xx error instead since it's just generating spam for us.
    if (request.cookies.key? '_session_id' and
        request.cookies['_session_id'].include? "\u0000") or
        (request.cookies.key? '_hkn-rails_session' and
        request.cookies['_hkn-rails_session'].include? "\u0000")
      render text: "400 Bad Request", status: 400 and return
    end

    if UserSession.find
      @real_current_user = UserSession.find.person

      if suu = current_su_user  # this checks permissions too
        @current_user = suu
      else
        session.delete(:su) if session[:su]
        @current_user = @real_current_user
      end
    end
  end

  def merge_messages
    @messages ||= []
    @debug ||= []
    if flash[:notice]
      @messages << flash[:notice]
    end
  end

  def check_authorizations
    @auth ||= {}
    unless @current_user.nil?
      if @current_user.admin?
        @auth.default = true
      else
        @current_user.groups.each do |group|
          @auth[group.name] = true
        end
      end
      @auth['comms'] = @auth['cmembers'] || @auth['assistants'] || @auth['officers']
    end
  end

  def set_view_variables
    @easter_eggs = {
      piglatin:  session[:piglatin],
      moonspeak: session[:moonspeak],
      mirror:    session[:mirror],
      acid:      session[:acid],
      b:         session[:b],
      dt:        session[:dt],
      kappa:     session[:kappa],
    }

    if @easter_eggs.values.any?
      msg = ["The following easter eggs are currently enabled:"]
      msg << @easter_eggs.select{|k,v|v}.collect{|x|x.first.to_s.titleize}.join('<br/>')
      msg << "To change your settings, please go <a href='#{easter_eggs_edit_path}'>here</a>".html_safe
      @messages << msg.join('<br/>').html_safe
    end
  end

  def su(username)
    if username.nil?
      session.delete(:su)
      get_current_user
      return true
    end

    if @current_user and @current_user.admin? and user = Person.exists?(username: username)
      session[:su] = username
      get_current_user
      return true
    else
      return false
    end
  end

  def current_su_user
    @real_current_user and @real_current_user.admin? and session[:su] and Person.find_by_username(session[:su])
  end

  def impersonating?
    @current_user && @current_user != @real_current_user
  end

  def redirect_back_or_default(path, *args)
    send(:redirect_to, request.referer || path, *args)
  end


end
