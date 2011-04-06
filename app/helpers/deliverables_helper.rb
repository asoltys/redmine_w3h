module DeliverablesHelper

  include CustomFieldsHelper

  # Helper to generate a form used to calculate the total budget while editing
  # a Deliverable
  # TODO Later: Refactor since observers are not used anymore
  def field_with_budget_observer_and_totals(form, object, field, percent_field, default_value='')
    content_tag(:tr,
                content_tag(:td, "<label for='deliverable_#{field.to_s}'>#{l_field(field, 'field_')}</label>") +
                content_tag(:td, number_or_percent_field(object, field, percent_field, default_value, :size => 7)) +
                content_tag(:td,
                            content_tag(:span,
                                        0,
                                        :class => "budget-calculation",
                                        :id => field.to_s + '_subtotal'
                                        ),
                            :class => "calculation-column"
                            ))
                            
  end

  def number_or_percent_field(object, number_field, percent_field, default_value, options)
    # Build a text_field by hand named after the number field but with the percent_field and % as the value
    return text_field_tag('deliverable_' + number_field.to_s, 
                          object.read_attribute(percent_field).to_s + "%",
                          options.merge({ :name => "deliverable[#{number_field.to_s}]"})) unless object.read_attribute(percent_field).blank?
    
    # Number and fallback with no values
    value = object.read_attribute(number_field) || default_value || ''
    return text_field(:deliverable, number_field, options.merge({ :value => value}))
  end
  
  # Helper to generate a consistant HTML format for displaying basic data
  def paragraph_with_data(label, data)
    content_tag(:p,
                content_tag(:span, label, :class => 'title') +
                content_tag(:span, h(data), :class => 'data'))
  end
  
  def row_with_data(label, data, css_class='')
    content_tag(:tr,
                content_tag(:td, label, :class => 'title') +
                content_tag(:td, h(data), :class => 'data'),
                :class => css_class)
  end

  # Helper to generate a consistant HTML format for displaying basic data
  def paragraph_with_double_data(label, data1, data2)
    content_tag(:p,
                content_tag(:span, label, :class => 'title') +
                content_tag(:span,
                            content_tag(:span, h(data1), :class => 'left-data') +
                            content_tag(:span, h(data2), :class => 'right-data'),
                            :class => 'fake-table'))
                
  end

  # Helper to generate a consistant HTML format for displaying basic data
  def row_with_double_data(label, data1, data2, css_class='')
    content_tag(:tr,
                content_tag(:td, label, :class => 'title') +
                content_tag(:td, h(data1), :class => 'data') +
                content_tag(:td, h(data2), :class => 'data'),
                :class => css_class)
  end

  # Check if the current user is allowed to manage the budget.  Based on Role permissions.
  def allowed_management?
    return User.current.allowed_to?(:manage_budget, @project)
  end
  
  def l_field(field, prefix='')
    l((prefix + field.to_s).to_sym)
  end
  
  def toggle_arrows(deliverable_id)
    open_js = "expandRow(#{deliverable_id})"
    close_js = "collapseRow(#{deliverable_id})"

    return toggle_arrow(deliverable_id, "toggle-arrow-closed.gif", open_js, false) +
      toggle_arrow(deliverable_id, "toggle-arrow-open.gif", close_js, true)
  end
  
  def toggle_arrow(deliverable_id, image, js, hide=false)
    style = "display:none;" if hide
    style ||= ''

    content_tag(:span,
                link_to_function(image_tag(image, :plugin => "redmine_w3h"), js),
                :class => "toggle toggle_" + deliverable_id.to_s,
                :style => style
                )
    
  end
  
  def number_or_percent(number_field, percent_field)
    return number_to_currency(number_field, :precision => 0) unless number_field.blank?
    return number_to_percentage(percent_field, :precision => 0) unless percent_field.blank?
    return "$0"
  end
	
	def budget_custom_table(deliverable, is_header)			
		unless deliverable.custom_field_values.empty?
			table_columns = 7
			custom_spaces = 4
			row_count = 0
			row_max = (deliverable.custom_field_values.size / custom_spaces.to_f).ceil
			if (deliverable.custom_field_values.size % custom_spaces) == 0
				custom_mod = custom_spaces
			else
				custom_mod = (deliverable.custom_field_values.size % custom_spaces)
			end
			
			while row_count < row_max do
				custom_index = row_count * custom_spaces
				concat("<tr>")
				if (row_max - row_count) == 1
					head_space = table_columns - custom_mod
					custom_increment = custom_mod - 1
				else
					head_space = 3
					custom_increment = 3
				end
				while head_space > 0 do
					if is_header
						concat(content_tag('th', " "))
					else
						concat(content_tag('td', " "))
					end
					head_space -= 1
				end
				for custom_index in custom_index..custom_index+custom_increment do
					if is_header
						concat(content_tag('th',@deliverable_custom_fields[custom_index].name))
					else
						concat(content_tag('td',number_to_currency(show_value(deliverable.custom_field_values[custom_index]).to_f, :precision => 2), {:align => 'center'}))
					end
				end
				concat("</tr>")
				row_count += 1
			end
		end
	end
end
