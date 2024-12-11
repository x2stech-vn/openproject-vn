module TimeEntries
  class TimeEntryForm < ApplicationForm
    include CustomFields::CustomFieldRendering

    form do |f|
      f.autocompleter(
        name: :user_id,
        id: "time_entry_user_id",
        label: TimeEntry.human_attribute_name(:user),
        required: true,
        autocomplete_options: {
          defaultData: true,
          hiddenFieldAction: "change->time-entry#userChanged",
          component: "opce-user-autocompleter",
          url: ::API::V3::Utilities::PathHelper::ApiV3Path.principals,
          filters: user_completer_filter_options,
          searchKey: "any_name_attribute",
          resource: "principals",
          focusDirectly: false,
          multiple: false,
          appendTo: "#time-entry-dialog",
          disabled: !show_user_field?
        }
      )

      f.single_date_picker name: :spent_on,
                           type: "date",
                           required: true,
                           datepicker_options: { inDialog: true },
                           value: model.spent_on&.iso8601,
                           label: TimeEntry.human_attribute_name(:spent_on)

      if show_start_and_end_time_fields?
        f.group(layout: :horizontal) do |g|
          g.text_field name: :start_time,
                       type: "time",
                       required: true,
                       label: TimeEntry.human_attribute_name(:start_time),
                       value: model.start_timestamp&.strftime("%H:%M"),
                       data: {
                         "time-entry-target" => "startTimeInput",
                         "action" => "input->time-entry#timeInputChanged"
                       }

          g.text_field name: :end_time,
                       type: "time",
                       required: true,
                       label: TimeEntry.human_attribute_name(:end_time),
                       value: model.end_timestamp&.strftime("%H:%M"),
                       data: {
                         "time-entry-target" => "endTimeInput",
                         "action" => "input->time-entry#timeInputChanged"
                       }
        end
      end

      f.text_field name: :hours,
                   required: true,
                   label: TimeEntry.human_attribute_name(:hours),
                   value: model.hours.present? ? ChronicDuration.output(model.hours * 3600, format: :hours_only) : "",
                   data: { "time-entry-target" => "hoursInput",
                           "action" => "blur->time-entry#hoursChanged keypress.enter->time-entry#hoursKeyEnterPress" }

      f.work_package_autocompleter name: :work_package_id,
                                   label: TimeEntry.human_attribute_name(:work_package),
                                   required: true,
                                   autocomplete_options: {
                                     focusDirectly: false,
                                     append_to: "#time-entry-dialog",
                                     filters: [
                                       { name: "project_id", operator: "=", values: [model.project_id] }
                                     ]
                                   }

      f.autocompleter(
        name: :activity_id,
        label: TimeEntry.human_attribute_name(:activity),
        required: false,
        include_blank: true,
        autocomplete_options: {
          focusDirectly: false,
          multiple: false,
          decorated: true,
          append_to: "#time-entry-dialog"
        }
      ) do |select|
        activities.each do |activity|
          select.option(value: activity.id, label: activity.name, selected: (model.activity_id == activity.id))
        end
      end

      f.text_area name: :comments, label: TimeEntry.human_attribute_name(:comments)

      render_custom_fields(form: f)
    end

    def additional_custom_field_input_arguments
      { wrapper_id: "#time-entry-dialog" }
    end

    private

    delegate :project, :work_package, to: :model

    def custom_fields
      @custom_fields ||= model.available_custom_fields
    end

    def show_user_field?
      # Only allow setting a different user, when the user has the
      # permission to log time for others in the project
      User.current.allowed_in_project?(:log_time, project)
    end

    def show_start_and_end_time_fields?
      TimeEntry.can_track_start_and_end_time?
    end

    def activities
      TimeEntryActivity.active_in_project(project)
    end

    def user_autocompleter_filter_options
      filters = [
        { name: "type", operator: "=", values: %w[User Group] },
        { name: "status", operator: "=", values: [Principal.statuses[:active], Principal.statuses[:invited]] }
      ]

      if model.project_id
        filters << { name: "member", operator: "=", values: [model.project_id] }
      end

      filters
    end
  end
end
