
class MugshotsController < ApplicationController
  
  append_before_filter :load_user, :only => [:create,:new]
  append_before_filter :load_mugshot, :only => [:show,:edit,:update,:destroy]
  append_before_filter :login_required, :except => [:show]
  
  def authorized?
    (@user || (@mugshot.user rescue nil)) == current_user or admin?
  end
  
  def show
  end
  
  def edit
  end
  
  def new
    @mugshot = Mugshot.new
  end
  
  def destroy
    mugshot = @mugshot.destroy
    
    if mugshot.user
      @user = mugshot.user
      render(:update) {|p| p.replace_html :mugshot, :partial => 'users/mugshot'}
    end
  end
  
  def update
    @mugshot.uploaded_data = params[:mugshot][:uploaded_data]
    @mugshot.save!
    
    flash[:notice] = 'Mugshot was successfully updated.'
    
    if @mugshot.user
      redirect_to user_url(@mugshot.user)
    else
      redirect_to mugshot_url(@mugshot)
    end
  rescue
    raise $!
    logger.debug "err #{$!}"
    flash[:notice] = "Failed to update mugshot #{$!}"
    render :action => :edit
  end
  
  def create
    @mugshot = Mugshot.new(params[:mugshot])
    @mugshot.user = @user
    @mugshot.save!
    
    flash[:notice] = "Mugshot was successfully created."
      
    redirect_to user_url(@mugshot.user)
  rescue
    raise $!
    flash[:notice] = "Failed to create mugshot. #{$!} #{$!.backtrace * '<br/>'}"
    render :action => :new
  end
  
  def update_all_thumbnails
    Mugshot.find(:all, :conditions => {:parent_id => nil}).each { |a| a.update_thumbnails }
    redirect_to '/'
  end
  
  protected
  def load_user
    @user = User.find(params[:user_id])
  end
  def load_mugshot
    @mugshot = Mugshot.find(params[:id])
  end
end
