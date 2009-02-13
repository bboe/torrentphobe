require 'app/controllers/admin/swarms_controller'

class Admin::SwarmsController
  def facebook_session
    @_test_mock_fb_session
  end

  def facebook_session= f_session
    @_test_mock_fb_session = f_session
  end
end
