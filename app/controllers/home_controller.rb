class HomeController < ApplicationController
  layout "main"
  before_filter :login_required
  def index
    @current_user = get_current_user

    @torrents = paginated_torrents @current_user, 5, {:conditions => ["torrents.created_at > :date" , {:date => 14.days.ago}], :limit => 10, :order => "torrents.created_at DESC" }

    @new_users = @current_user.friends.map { |user| user if user.created_at > 5.days.ago }.compact

    respond_to do |format|
        format.html # index.html.erb
    end
  end
end
