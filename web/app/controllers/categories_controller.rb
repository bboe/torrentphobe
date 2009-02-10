class CategoriesController < ApplicationController
  layout 'main'

  # GET /categories
  # GET /categories.xml
  def index
    ordering = handle_sort params




    uid = session[:user_id]
    user = User.find_by_id(uid)
    
    user_torrents = Torrent.find_all_by_owner_id(uid)

    @torrents = []
    @torrents = user.friends.map {|friend| friend.torrents }
    @torrents << user.torrents
    @torrents << user_torrents
    
    @torrents = @torrents.flatten.uniq
    if @torrents
       case params[:c] 
       when "size"
	  @torrents = @torrents.sort_by { |torrent| torrent.size } 
       else
	  @torrents = @torrents.sort_by { |torrent| torrent.name } 
       end
       if params[:d] == "up"
	 @torrents = @torrents.reverse
       end
    end
    


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

       uid = session[:user_id]
       user = User.find_by_id(uid)
       
       user_torrents = Torrent.find_all_by_owner_id_and_category_id(uid, @category.id)

       @torrents = []
       @torrents = user.friends.map {|friend| friend.torrents }
       @torrents << user.torrents
       @torrents << user_torrents
       
       @torrents = @torrents.flatten.uniq
       @torrents = @torrents.select{ |torrent| torrent.category_id == @category.id} 
       if @torrents
	  case params[:c] 
	  when "size"
	     @torrents = @torrents.sort_by { |torrent| torrent.size } 
	  else
	     @torrents = @torrents.sort_by { |torrent| torrent.name } 
	  end
	  if params[:d] == "up"
	    @torrents = @torrents.reverse
	  end
       end
# END RIP

        respond_to do |format|
            format.html # show.html.erb
            format.xml  { render :xml => @category }
        end
    end   
  end
end
