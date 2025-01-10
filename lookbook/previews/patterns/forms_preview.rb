# frozen_string_literal: true

module Patterns
  # @hidden
  class FormsPreview < ViewComponent::Preview
    # @display min_height 500px
    def default; end

    # @display min_height 300px
    # @label Overview
    def custom_width_fields_form; end

    # @label Preview
    # @param answer
    def form_preview(answer: nil)
      preview_path =
        Lookbook::Engine
          .routes
          .url_helpers
          .lookbook_preview_path(path: "patterns/forms/form_preview")
      render_with_template(locals: { answer:, preview_path: })
    end
  end
end
