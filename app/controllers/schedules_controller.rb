class SchedulesController < ApplicationController
  before_action :authenticate_user

  def index
    get_schedules = GetSchedules.new
    render json: { data: get_schedules.perform }, status: 200
  end

  def create
    create_schedule = CreateSchedule.new(create_params)
    if create_schedule.perform
      render json: {
        data: {
          schedule: {
            id: create_schedule.schedule.id,
            start_time: create_schedule.schedule.start_time.strftime('%Y-%m-%d %H:%M:%S'),
            end_time: create_schedule.schedule.end_time.strftime('%Y-%m-%d %H:%M:%S'),
          }
        }
      }, status: 201
    else
      render json: { error: { message: create_schedule.errors.first.full_message } }, status: 422
    end

  rescue ActionController::ParameterMissing => e
    render json: { error: { message: "#{e.param} must not be empty" } }, status: 400
  end

  def update
    udpate_schedule = UpdateSchedule.new(update_params)

    if udpate_schedule.perform(params[:id])
      render json: { data: { message: 'success' } }, status: 201
    else
      render json: { error: { message: udpate_schedule.errors.first.full_message } }, status: 422
    end

  rescue ActiveRecord::RecordNotFound
    render json: { error: { message: "schedule not found" } }, status: 404
  rescue ActionController::ParameterMissing => e
    render json: { error: { message: "#{e.param} must not be empty" } }, status: 400
  end

  def destroy
    delete_schedule = DeleteSchedule.new

    if delete_schedule.perform(params[:id])
      render json: { data: { message: "success" } }, status: 200
    end

  rescue ActiveRecord::RecordNotFound
    render json: { error: { message: "schedule not found" } }, status: 404
  end

  private

  def create_params
    params.require([:user_email, :room_name, :schedule]).last.require([:start_time, :end_time])
    params.permit(:user_email, :room_name, :guests, schedule: [:start_time, :end_time], guests: [:email])
  end

  def update_params
    params.require(:schedule).require([:start_time, :end_time])
    params.permit(schedule: [:start_time, :end_time])
  end
end
