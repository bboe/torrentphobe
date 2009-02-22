class HomeController < ApplicationController
  layout "main"
  before_filter :login_required
  def index
    @current_user = get_current_user

    ordering = handle_sort params
    @torrents = @current_user.my_torrents

    @torrents.sort! { |a,b| a.created_at <=> b.created_at }
    @torrents = @torrents.reverse[0..5]

    @new_users = @current_user.friends.map { |user| user if user.created_at > 5.days.ago }.compact

    respond_to do |format|
        format.html # index.html.erb
    end
  end
end
