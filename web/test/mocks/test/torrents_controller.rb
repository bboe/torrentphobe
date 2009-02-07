require 'app/controllers/torrents_controller'

class TorrentsController
  def facebook_session
    @_test_mock_fb_session
  end

  def facebook_session= f_session
    @_test_mock_fb_session = f_session
  end
end
