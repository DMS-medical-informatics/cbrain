#
# CBRAIN Project
#
# Controller for site resource.
#
# Original author: Tarek Sherif
#
# $Id$
#

#RESTful controller for the Site resource.
class SitesController < ApplicationController
  
  Revision_info=CbrainFileRevision[__FILE__]
  
  before_filter :login_required 
  before_filter :admin_role_required, :except  => :show
  
  # GET /sites
  # GET /sites.xml
  def index #:nodoc:
    @filter_params["sort_hash"]["order"] ||= 'sites.name'
    
    @sites = base_filtered_scope Site.includes( [:users, :groups] )

    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.xml  { render :xml => @sites }
    end
  end

  # GET /sites/1
  # GET /sites/1.xml
  def show #:nodoc:
    @site = current_user.has_role?(:admin) ? Site.find(params[:id]) : current_user.site

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @site }
    end
  end
 
  def new #:nodoc:
    @site = Site.new
    render :partial => "new"
  end
 
  # GET /sites/1/edit
  def edit #:nodoc:
    @site = Site.find(params[:id])
  end

  # POST /sites
  # POST /sites.xml
  def create #:nodoc:
    @site = Site.new(params[:site])

    respond_to do |format|
      if @site.save
        flash[:notice] = 'Site was successfully created.'
        format.js  { redirect_to :action => :index, :format => :js }
        format.xml { render :xml => @site, :status => :created, :location => @site }
      else
        format.js  {render :partial  => 'shared/failed_create', :locals  => {:model_name  => 'site' }}
        format.xml { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sites/1
  # PUT /sites/1.xml
  def update #:nodoc:
    @site = Site.find(params[:id])
    params[:site][:user_ids]    ||= []
    params[:site][:manager_ids] ||= []
    params[:site][:group_ids]   ||= [ @site.own_group.id ]
    params[:site][:user_ids].map!    &:to_i
    params[:site][:manager_ids].map! &:to_i
    params[:site][:group_ids].map!   &:to_i
    
    @site.unset_managers

    respond_to do |format|
      if @site.update_attributes(params[:site])
        flash[:notice] = 'Site was successfully updated.'
        format.html { redirect_to(@site) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sites/1
  # DELETE /sites/1.xml
  def destroy #:nodoc:
    @site = Site.find(params[:id])
    @site.destroy

    respond_to do |format|
      format.js   { redirect_to :action => :index, :format => :js }
      format.xml  { head :ok }
    end
  end
end
