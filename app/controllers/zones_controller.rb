class ZonesController < ApplicationController

  before_action { params[:id] && @zone = Zone.find(params[:id]) }

  def index
    @zones = Zone.order(:updated_at => :desc).includes(:pending_changes)
  end

  def show
    @records = @zone.records.order(:name, :type).to_a
  end

  def zone_file
    render :plain => @zone.generate_zone_file
  end

  def new
    @zone = Zone.new
  end

  def create
    @zone = Zone.new(safe_params)
    if @zone.save
      redirect_to @zone, :notice => "#{@zone.name} has been created successfully"
    else
      render 'new'
    end
  end

  def update
    if @zone.update(safe_params)
      redirect_to @zone, :notice => "#{@zone.name} has been updated successfully"
    else
      render 'edit'
    end
  end

  def destroy
    @zone.destroy
    redirect_to root_path, :notice => "#{@zone.name} has been removed successfully"
  end

  def publish
    if request.post?
      publisher = Bound::Publisher.new(:all => Change.pending.empty?)
      publisher.publish
      @result = publisher.result
      render 'publish_results'
    else
      @changes = Change.pending.order(:created_at)
    end
  end

  def import
    @import = Bound::Import.new(@zone, params[:records])
    if params[:import].present?
      imported_records = @import.import
      redirect_to @zone, :notice => "Imported #{imported_records.size} of #{@import.records.size} record(s)"
    end
  end

  private

  def safe_params
    params.require(:zone).permit(:name, :primary_ns, :email_address, :refresh_time, :retry_time, :expiration_time, :max_cache, :ttl)
  end

end
