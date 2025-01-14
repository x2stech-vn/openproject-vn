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

require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper.rb")

RSpec.describe "time entry dialog", :js, with_flag: :track_start_and_end_times_for_time_entries do
  shared_let(:project) { create(:project_with_types) }

  shared_let(:work_package_a) { create(:work_package, subject: "WP A", project:) }
  shared_let(:work_package_b) { create(:work_package, subject: "WP B", project:) }

  let(:wp_view_a) { Pages::FullWorkPackage.new(work_package_a) }
  let(:wp_view_b) { Pages::FullWorkPackage.new(work_package_b) }
  let(:time_logging_modal) { Components::TimeLoggingModal.new }

  let(:user) { create(:user, member_with_permissions: { project => permissions }) }

  before do
    login_as user
  end

  context "when user has permission to log own time" do
    let(:permissions) { %i[log_own_time view_own_time_entries view_work_packages] }

    context "when start and end time is not allowed", with_settings: { allow_tracking_start_and_end_times: false } do
    end

    context "when start and end time is allowed", with_settings: { allow_tracking_start_and_end_times: true } do
    end

    context "when start and end time is enforced",
            with_settings: { allow_tracking_start_and_end_times: true, enforce_tracking_start_and_end_times: true } do
    end
  end

  context "when user has permission to log time for others" do
    let!(:other_user) { create(:user, member_with_permissions: { project => [:view_project] }) }
    let(:permissions) { %i[log_time view_time_entries view_work_packages] }
  end

  context "when user has permission to edit own time entries" do
    let(:permissions) { %i[log_own_time view_own_time_entries edit_own_time_entries view_work_packages] }
  end

  context "when user has permission to edit time entries for others" do
    let!(:other_user) { create(:user, member_with_permissions: { project => [:view_project] }) }
    let(:permissions) { %i[log_time view_time_entries edit_time_entries view_work_packages] }
  end
end
