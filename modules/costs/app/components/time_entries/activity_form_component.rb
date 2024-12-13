module TimeEntries
  class ActivityFormComponent < ApplicationComponent
    include OpTurbo::Streamable

    attr_reader :form

    def initialize(form:)
      super()
      @form = form
    end

    def call
      component_wrapper do
        render(TimeEntries::ActivityForm.new(form))
      end
    end
  end
end
