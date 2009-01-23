class SwarmsController < ApplicationController
  # GET /swarms
  # GET /swarms.xml
  def index
    @swarms = Swarm.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @swarms }
    end
  end

  # GET /swarms/1
  # GET /swarms/1.xml
  def show
    @swarm = Swarm.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @swarm }
    end
  end

  # GET /swarms/new
  # GET /swarms/new.xml
  def new
    @swarm = Swarm.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @swarm }
    end
  end

  # GET /swarms/1/edit
  def edit
    @swarm = Swarm.find(params[:id])
  end

  # POST /swarms
  # POST /swarms.xml
  def create
    @swarm = Swarm.new(params[:swarm])

    respond_to do |format|
      if @swarm.save
        flash[:notice] = 'Swarm was successfully created.'
        format.html { redirect_to(@swarm) }
        format.xml  { render :xml => @swarm, :status => :created, :location => @swarm }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @swarm.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /swarms/1
  # PUT /swarms/1.xml
  def update
    @swarm = Swarm.find(params[:id])

    respond_to do |format|
      if @swarm.update_attributes(params[:swarm])
        flash[:notice] = 'Swarm was successfully updated.'
        format.html { redirect_to(@swarm) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @swarm.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /swarms/1
  # DELETE /swarms/1.xml
  def destroy
    @swarm = Swarm.find(params[:id])
    @swarm.destroy

    respond_to do |format|
      format.html { redirect_to(swarms_url) }
      format.xml  { head :ok }
    end
  end
end
