class MainController < ApplicationController
  def index
  end

  def invite
    @inviteid = params[:inviteid]
    if @inviteid.length == 20
      @invite = Invitation.find_by_inviteid(@inviteid)
    end

    if @invite.nil?
      render :action => :not_found
    end
  end

  def approve
    abort params.inspect
    @inviteid = params[:inviteid]
    if @inviteid.length == 20
      @invite = Invitation.find_by_inviteid(@inviteid)
    end

    if @invite.nil?
      render :action => :not_found
    else
      @invite.guests.delete_all
      params[:names].each_with_index do |name, i|
        Guest.create(:name => name, :meal => params[:meals][i], :drink => params[:drinks][i], :invitation => @invite)
      end
    end
    redirect_to showinvite_url(@invite.inviteid) 
  end

  def not_found

  end
end
