class CategoriesController < ApplicationController
  layout 'main'
  before_filter :login_required

  # GET /categories
  # GET /categories.xml
  def index
    ordering = handle_sort params

    @current_user = get_current_user
    
    @torrents = @current_user.available_torrents
    @torrents = Category.sort_torrents(@torrents, params[:c], params[:d])

    @category = {}
    Category.find(:all).each { |c| @category[c.id]=c.name }
    @torrents_by_category = @torrents.group_by(&:category_id).sort

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    begin
        @category = Category.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        logger.error("Attempt to access invalid category #{params[:id]}" )
        flash[:notice] = "Whoops, thats not a valid category!"
        redirect_to :action => :index
    else
       ordering = handle_sort params

       @current_user = get_current_user
       
       @torrents = @current_user.available_torrents
       @torrents = @torrents.select{ |torrent| torrent.category_id == @category.id} 
       @torrents = Category.sort_torrents(@torrents, params[:c], params[:d])
        respond_to do |format|
            format.html # show.html.erb
            format.xml  { render :xml => @category }
        end
    end   
  end
end
