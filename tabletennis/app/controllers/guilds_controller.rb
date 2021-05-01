class GuildsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_guild, only: [:accept_to_guild, :check_user_role, :show, :edit]
  before_action :check_guild_mem, only: [:new, :create, :accept_to_guild]
  before_action :check_user_role, only: [:edit]

  def index
    @guilds = Guild.all
    @guilds = @guilds.sort_by(&:rating).reverse
  end

  def new
    @guild = Guild.new
  end

  def show
    @gm = @guild.guild_members
    @owner = @guild.guild_members.where(user_role: 2)
  end

  def edit
  end

  def create
    guild = Guild.new(guild_params)
    
    if guild.save
      guild_members = GuildMember.create(user_role: 2, user: current_user, guild: guild)
      redirect_to guild, notice: "Guild successfully created"
    else
      redirect_to new_guild_path, alert: 'Guild not created because some fields wrong'
    end
  end
  
  def accept_to_guild
    guild_members = GuildMember.create(user_role: 0, user: current_user, guild: @guild)
    redirect_back fallback_location: { action: "show" }, notice: "You are join to this guild"
  end
  
  def leave_from_guild
    if current_user.guild_member[:user_role] == 2
      guild = Guild.find(params[:id])
      guild.destroy
      redirect_to guilds_path, notice: "Guild has been destroyed"
    else
      current_user.guild_member.destroy
      redirect_back fallback_location: { action: "index" }, notice: "You are succsessfully leave from this guild"
    end
  end

  private

  def check_user_role
    unless current_user.guild && current_user.guild.user_owner?(current_user, @guild) # todo добавить alert на то что чел не в гильдии
      redirect_to guild_path, alert: "You are not owner for edit"
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_guild
    @guild = Guild.find(params[:id])
  end
  
  # Only allow a list of trusted parameters through.
  def guild_params
    p params
    p params.require(:guild).permit(:name, :anagram, :description, :rating)
  end
  
  def check_guild_mem
    if current_user.guild
      redirect_back fallback_location: { action: "index" }, alert: "you are already in guild"
    end
  end
  
end

