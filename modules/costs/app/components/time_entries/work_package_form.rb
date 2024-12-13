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
  class WorkPackageForm < ApplicationForm
    form do |f|
      f.work_package_autocompleter name: :work_package_id,
                                   label: TimeEntry.human_attribute_name(:work_package),
                                   required: true,
                                   autocomplete_options: {
                                     hiddenFieldAction: "change->time-entry#workPackageChanged",
                                     focusDirectly: false,
                                     append_to: "#time-entry-dialog",
                                     url: work_package_completer_url,
                                     filters: work_package_completer_filters
                                   }
    end

    private

    def work_package_completer_url
      if model.persisted?
        ::API::V3::Utilities::PathHelper::ApiV3Path.time_entries_available_work_packages_on_edit(model.id)
      else
        ::API::V3::Utilities::PathHelper::ApiV3Path.time_entries_available_work_packages_on_create
      end
    end

    def work_package_completer_filters
      filters = []

      if model.project_id
        filters << { name: "project_id", operator: "=", values: [model.project_id] }
      end

      filters
    end
  end
end
