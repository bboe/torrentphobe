class CategoriesController < ApplicationController
  layout 'main'

  # GET /categories
  # GET /categories.xml
  def index
    @categories = Category.find(:all)
    @counts = Torrent.count(:group => 'category_id')

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
        @torrents = Torrent.find(:all, :conditions => [ "category_id= ?" , params[:id] ])
        respond_to do |format|
            format.html # show.html.erb
            format.xml  { render :xml => @category }
        end
    end   
  end
end
