require 'app/controllers/admin/taggings_controller'

class Admin::TaggingsController
  def facebook_session
    @_test_mock_fb_session
  end

  def facebook_session= f_session
    @_test_mock_fb_session = f_session
  end
end
