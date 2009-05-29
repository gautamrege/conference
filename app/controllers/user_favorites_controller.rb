class UserFavoritesController < ApplicationController
  before_filter :assert_user
  before_filter :login_required, :only => :modify
  before_filter :assert_record_ownership, :only => :modify

  # GET /favorites
  # GET /favorites.xml
  # GET /favorites.json
  def index
    # TODO Document what :join does or remove it.
    if params[:join] == "1"
      @user_favorites = UserFavorite.find_all_by_user_id(@user.id)
    else
      @user_favorites = @user.favorites
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_favorites }
      format.json  { render :json => @user_favorites }
      format.ics {
        render :text => Proposal.to_icalendar(
          @user_favorites, 
          :title => "#{@user.possessive_label(false)} favorites",
          :url_helper => lambda {|item| session_url(item)})
      }
    end
  end

  # PUT /favorites/1.xml
  # PUT /favorites/1.json
  def modify
    unless params[:proposal_id].blank? || params[:mode].blank? || !['add','remove'].include?(params[:mode])
      @user_favorite = \
        case params[:mode]
        when 'add'
          UserFavorite.add(@user.id, params[:proposal_id])
        when 'remove'
          UserFavorite.remove(@user.id, params[:proposal_id])
        end

      respond_to do |format|
        format.xml  { head :ok }
        format.json  { render :json => @user_favorite }
      end
    else
      errors = {:error => 'Malformed request.'}
      respond_to do |format|
        format.xml  { render :xml => errors, :status => :unprocessable_entity }
        format.json  { render :json => errors, :status => :unprocessable_entity }
      end
    end
  end

end
