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

module Components
  class TimeLoggingModal
    include Capybara::DSL
    include Capybara::RSpecMatchers
    include RSpec::Matchers
    include ::Components::Autocompleter::AutocompleteHelpers

    def is_visible(visible)
      if visible
        within modal_container do
          expect(page).to have_text(I18n.t("button_log_time"))
        end
      else
        expect(page).to have_no_css "dialog#time-entry-dialog"
      end
    end

    def change_hours(value)
      within modal_container do
        fill_in "time_entry_hours", with: value
      end
    end

    def submit
      within modal_container do
        click_on I18n.t("button_log_time")
      end
    end

    def cancel
      within modal_container do
        click_on I18n.t("button_cancel")
      end
    end

    def has_field_with_value(field, value)
      puts "*" * 100, modal_container.native["innerHTML"], "*" * 100
      within modal_container do
        expect(page).to have_field "input#time_entry_#{field}", with: value, visible: :all
      end
    end

    def expect_work_package(subject)
      within modal_container do
        expect(page).to have_css(".ng-value", text: subject, wait: 10)
      end
    end

    def shows_field(field, visible)
      within modal_container do
        if visible
          expect(page).to have_css "##{field_identifier(field)}"
        else
          expect(page).to have_no_css "##{field_identifier(field)}"
        end
      end
    end

    def update_field(field_name, value)
      field = field_object field_name
      if field_name == "user"
        field.unset_value
        field.autocomplete value
      else
        field.input_element.click
        field.set_value value
      end
    end

    def update_work_package_field(value, recent = false)
      work_package_field.input_element.click

      if recent
        within(".ng-dropdown-header") do
          click_link(I18n.t("js.label_recent"))
        end
      end

      work_package_field.set_value(value)
    end

    def perform_action(action)
      within modal_container do
        click_button action
      end
    end

    def activity_input_disabled_because_work_package_missing?(missing)
      if missing
        expect(modal_container).to have_field "input#time_entry_activity_id:disabled",
                                              with: I18n.t("placeholder_activity_select_work_package_first")
      else
        expect(modal_container).to have_field "input#time_entry_activity_id:enabled", visible: :all
      end
    end

    def has_hidden_work_package_field_for(work_package)
      expect(modal_container).to have_field "input#time_entry_work_package_id",
                                            with: work_package.id,
                                            type: :hidden
    end

    private

    def modal_container
      page.find("dialog#time-entry-dialog")
    end
  end
end
