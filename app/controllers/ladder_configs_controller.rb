class LadderConfigsController < ApplicationController



  def new
    @ladder = Ladder.find(params[:ladder_id].to_i)
    @ladder_config = LadderConfig.new
    @ladder_config.ladder = @ladder
  end

  def create
    @ladder = Ladder.find(params[:ladder_id])
    @ladder_config = LadderConfig.new(ladder_config_params)
    @ladder_config.ladder = @ladder
    if @ladder_config.save
      redirect_to @ladder, notice: 'COnfiguration for the ladder was successfully created.'
    else
      render :new
    end
  end



  def edit
    @ladder_config = LadderConfig.find(params[:id])
  end

  def update
    @ladder_config = LadderConfig.find(params[:id])
    if @ladder_config.update_attributes(ladder_config_params)
      if @ladder_config.is_default
        flash[:notice] = "Default ladder config updated successfully."
        redirect_to edit_ladder_config_path(@ladder_config)
      else
        flash[:notice] = "Ladder config updated successfully."
        redirect_to @ladder_config.ladder
      end
    else
      # wtf was that
      # @pages = Page.order('position ASC')
      # @section_count = LadderConfig.count
      render 'edit'
    end
  end

  private

  def ladder_config_params
    params.require(:ladder_config).permit(:default_score, :max_distance_between_players,
      :min_points_to_gain, :disproportion_factor, :unexpected_result_bonus, :hours_to_confirm)
  end

end
