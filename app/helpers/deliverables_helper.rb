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
      mod_factor = (deliverable.custom_field_values.size % custom_spaces)
			num_rows = (deliverable.custom_field_values.size / custom_spaces.to_f).ceil
      custom_mod = mod_factor ? mod_factor : custom_spaces

			(0..num_rows-1).each do |current_row|
				i = current_row * custom_spaces
        head_space = (num_rows - current_row) == 1 ? table_columns - custom_mod : 3
        custom_increment = (num_rows - current_row) == 1 ? custom_mod - 1 : 3
				
				concat("<tr>")
				head_space.times do 
          is_header ? concat(content_tag('th', " ")) : concat(content_tag('td', " "))
        end

				(i..i + custom_increment).each do |i|
					v = deliverable.custom_field_values[i]
					is_header ? budget_header_row(i) : budget_values_row(v)
				end
				concat("</tr>")
			end
		end
		return
	end

  def budget_header_row(i)
    concat(content_tag('th',@deliverable_custom_fields[i].name))
  end

  def budget_values_row(v)
    concat(content_tag('td', number_to_currency(show_value(v).to_f, 
     :precision => 2), {:align => 'center'}))
  end

  def fiscal_year_options
    min_date = Deliverable.minimum('due')
    max_date = Date.today.year + 1
    fiscal_years = (max_date..min_date).map{|d| "#{d.year}/#{(d.year + 1)}"}
    options_for_select(fiscal_years)
  end
end
