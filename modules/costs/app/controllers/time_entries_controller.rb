# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

class TimeEntriesController < ApplicationController
  include OpTurbo::ComponentStream
  include OpTurbo::DialogStreamHelper

  before_action :require_login

  with_options only: [:dialog] do
    before_action :load_and_authorize_optional_project
    before_action :load_and_authorize_optional_work_package
    before_action :load_or_build_and_authorize_time_entry
  end

  authorization_checked! :dialog, :create, :update, :user_tz_caption, :refresh_form, :destroy

  def dialog
    @show_work_package = params[:work_package_id].blank?
    @show_user = if @project
                   User.current.allowed_in_project?(:log_time, @project)
                 else
                   User.current.allowed_in_any_project?(:log_time)
                 end

    @time_entry.spent_on ||= params[:date].presence || Time.zone.today
  end

  def user_tz_caption
    user = User.visible.find_by(id: params[:user_id])
    caption = if user && user.time_zone != User.current.time_zone
                I18n.t("notice_different_time_zones", tz: helpers.friendly_timezone_name(user.time_zone))
              else
                ""
              end

    add_caption_to_input_element_via_turbo_stream('input[name="time_entry[user_id]"]',
                                                  caption:,
                                                  clean_other_captions: true)
    respond_with_turbo_streams
  end

  def refresh_form
    call = TimeEntries::SetAttributesService.new(
      user: current_user,
      model: TimeEntry.new,
      contract_class: EmptyContract
    ).call(permitted_params.time_entries)

    time_entry = call.result

    # TODO Some logic to figure out what fields we want to show (user, etc)

    replace_via_turbo_stream(
      component: TimeEntries::TimeEntryFormComponent.new(time_entry: time_entry, **form_config_options)
    )

    respond_with_turbo_streams
  end

  def create
    call = TimeEntries::CreateService
      .new(user: current_user)
      .call(permitted_params.time_entries)

    @time_entry = call.result

    unless call.success?
      form_component = TimeEntries::TimeEntryFormComponent.new(time_entry: @time_entry, **form_config_options)
      update_via_turbo_stream(component: form_component, status: :bad_request)

      respond_with_turbo_streams
    end
  end

  def update
    time_entry = TimeEntry.find_by(id: params[:id])

    call = TimeEntries::UpdateService
      .new(user: current_user, model: time_entry)
      .call(permitted_params.time_entries)

    @time_entry = call.result

    unless call.success?
      form_component = TimeEntries::TimeEntryFormComponent.new(time_entry: @time_entry, **form_config_options)
      update_via_turbo_stream(component: form_component, status: :bad_request)

      respond_with_turbo_streams
    end
  end

  def destroy
    time_entry = TimeEntry.find_by(id: params[:id])

    call = TimeEntries::DeleteService.new(user: current_user, model: time_entry).call

    @time_entry = call.result

    if call.success?
      # TODO: Render soimething that closes our dialog
    else
      form_component = TimeEntries::TimeEntryFormComponent.new(time_entry: @time_entry, **form_config_options)
      update_via_turbo_stream(component: form_component, status: :bad_request)
    end

    respond_with_turbo_streams
  end

  private

  def form_config_options
    {
      show_user: params[:time_entry][:show_user] == "true",
      show_work_package: params[:time_entry][:show_work_package] == "true"
    }
  end

  def load_and_authorize_optional_project
    if params[:project_id].present?
      @project = Project.visible.find(params[:project_id])
      # TODO: Authorize
    end
  rescue ActiveRecord::NotFound
    # noop
  end

  def load_and_authorize_optional_work_package
    if params[:work_package_id].present?
      @work_package = WorkPackage.visible.find_by(id: params[:work_package_id])
      @project = @work_package.project
      # TODO: Authorize
    end
  end

  def load_or_build_and_authorize_time_entry
    @time_entry = if params[:time_entry_id]
                    # TODO: Properly handle authorization
                    TimeEntry.find_by(id: params[:time_entry_id])
                  else
                    TimeEntry.new(project: @project, work_package: @work_package, user: User.current)
                  end
  end
end
