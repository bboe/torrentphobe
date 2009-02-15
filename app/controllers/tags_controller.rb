class TagsController < ApplicationController
  layout 'main'

  def index
    @tags = Tag.find(:all)
    @tag_counts = Torrent.tag_counts
    
    @tags.sort!{ |a,b| a.name.downcase <=> b.name.downcase }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  def show
    begin
        @tag = Tag.find(params[:id])
    rescue ActiveRecord::RecordNotFound
        logger.error("Attempt to access invalid tag #{params[:id]}" )
        flash[:notice] = "Whoops, thats not a valid tag!"
        redirect_to :action => :index
    else
        @torrents = Torrent.find_tagged_with(@tag)
        respond_to do |format|
            format.html # show.html.erb
            format.xml  { render :xml => @tags }
        end
    end

  end
end
