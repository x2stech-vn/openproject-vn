# frozen_string_literal: true

#-- copyright
# OpenProject is a project management system.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
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
# +

module OpenIDConnect
  class AssociateUserToken
    def initialize(user)
      @user = user
    end

    def call(access_token:, refresh_token: nil, known_audiences: [], clear_previous: false)
      if access_token.blank?
        Rails.logger.error("Could not associate token to user: No access token")
        return
      end

      if @user.nil?
        Rails.logger.error("Could not associate token to user: Can't find user")
        return
      end

      @user.oidc_user_tokens.destroy_all if clear_previous

      token = @user.oidc_user_tokens.build(access_token:, refresh_token:, audiences: Array(known_audiences))
      # We should discover further audiences from the token in the future
      token.save! if token.audiences.any?
    end
  end
end
