class CategoriesController < ApplicationController
  layout 'main'

  # GET /categories
  # GET /categories.xml
  def index
    ordering = handle_sort params

    @category = {}
    Category.find(:all).each { |c| @category[c.id]=c.name }
    @torrents_by_category = Torrent.find(:all, :order => ordering).group_by(&:category_id).sort

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
        @torrents = Torrent.find(:all, :order => ordering, :conditions => [ "category_id= ?" , params[:id] ])
        respond_to do |format|
            format.html # show.html.erb
            format.xml  { render :xml => @category }
        end
    end   
  end
end
