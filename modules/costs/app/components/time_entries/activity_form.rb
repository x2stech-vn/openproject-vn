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

module TimeEntries
  class ActivityForm < ApplicationForm
    form do |f|
      f.autocompleter(
        name: :activity_id,
        label: TimeEntry.human_attribute_name(:activity),
        visually_hide_label: true,
        required: false,
        include_blank: true,
        autocomplete_options: {
          placeholder: placeholder_text,
          focusDirectly: false,
          multiple: false,
          decorated: true,
          disabled: project.blank?,
          append_to: "#time-entry-dialog"
        }
      ) do |select|
        activities.each do |activity|
          select.option(value: activity.id, label: activity.name, selected: (model.activity_id == activity.id))
        end
      end
    end

    private

    delegate :project, to: :model

    def placeholder_text
      if project.blank?
        I18n.t("time_entry.activity_select_project_first")
      else
        I18n.t("time_entry.activity_select")
      end
    end

    def activities
      return [] if project.blank?

      TimeEntryActivity.active_in_project(project)
    end
  end
end
