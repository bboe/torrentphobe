module UsersHelper

  # This is a somewhat hacky way to verify that the user's facebook session
  # is valid.
  def user_logged_in?
    if facebook_session
      begin
        facebook_session.user.name
        return true
      rescue Facebooker::Session::SessionExpired
        return false
      end
    end
    return false
  end
end
