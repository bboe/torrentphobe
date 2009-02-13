require 'app/controllers/admin/users_controller'

class Admin::UsersController
  def facebook_session
    @_test_mock_fb_session
  end

  def facebook_session= f_session
    @_test_mock_fb_session = f_session
  end
end
