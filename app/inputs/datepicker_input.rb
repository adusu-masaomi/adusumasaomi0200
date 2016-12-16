class DatepickerInput < SimpleForm::Inputs::StringInput
 
  def initialize(builder, attribute_name, column, input_type, options = {})
    super(builder, attribute_name, column, :date, options)
  end
 
  def input
    options.deep_merge!(wrapper_html: { class: "large-3" })
    super
  end
end