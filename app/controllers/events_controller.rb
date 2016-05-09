class EventsController < ApplicationController
  before_action :set_event, :only => [ :show, :edit, :update, :destroy]

  def index
    sort_by = (params[:order] == 'name') ? 'name' : 'created_at'
    @events = Event.page(params[:page]).per(5)

    respond_to do |format|
    format.html # index.html.erb
    format.xml { render :xml => @events.to_xml }
    format.json { render :json => @events.to_json }
    format.atom { @feed_title = "My event list" } # index.atom.builder
    end
  end

  def join
    @event = Event.find(params[:id])
    Membership.find_or_create_by( :event => @event, :user => current_user )

    redirect_to :back
  end

  def withdraw
    @event = Event.find(params[:id] )
    @membership = Membership.find_by( :event => @event, :user => current_user )
    @membership.destroy

    redirect_to :back
  end

  def bulk_delete
    Event.destroy_all
    redirect_to events_path
  end

  def bulk_update
    ids = Array(params[:ids])
    events = ids.map{ |i| Event.find_by_id(i) }.compact

    if params[:commit] == "Publish"
      events.each{ |e| e.update( :status => "published" ) }
    elsif params[:commit] == "Delete"
      events.each{ |e| e.destroy }
    end

    redirect_to events_url
  end

  def dashboard
      @event = Event.find(params[:id])
  end

  def latest
    @events = Event.order("id DESC").limit(3)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
      if @event.save
        redirect_to events_url
      else
        render :action => :new
      end
    flash[:notice] = "event was successfully created"
  end

  def event_params
    params.require(:event).permit(:name, :description, :category_id, :location_attributes => [:id, :name, :_destroy], :group_ids => [] )
  end

  def show
    @event = Event.find(params[:id])
    respond_to do |format|
      format.html { @page_title = @event.name } # show.html.erb
      format.xml # show.xml.builder
      format.json { render :json => { id: @event.id, name: @event.name }.to_json }
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to event_url(@event)
    else
      render :action => :edit
    end
   flash[:notice] = "event was successfully updated"
  end

  def destroy
    @event.destroy

    redirect_to :action => :index
    flash[:alert] = "event was successfully deleted"
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

end
