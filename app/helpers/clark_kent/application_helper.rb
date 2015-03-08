module ClarkKent
  module ApplicationHelper

    def select_value_method(filter_param,example_option)
      if respond_to? "#{filter_param}_value_method"
        send "#{filter_param}_value_method"
      elsif example_option.respond_to? :id
        :id
      else
        :to_s
      end
    end

    def select_text_method(filter_param,example_option)
      if respond_to? "#{filter_param}_text_method"
        send "#{filter_param}_text_method"
      elsif example_option.respond_to? :name
        :name
      else
        :to_s
      end
    end

    def unit_id_value_method
      :id
    end

    def unit_id_text_method
      :full_name
    end

    def is_decimal?(value)
      (value =~ /\d/) && (value =~ /\./) && !(value =~ /[a-zA-Z]/)
    end

    def display_for_value(value, column_name=nil)
      return link_to(value, edit_manage_reservation_path(value)) if column_name == 'reservation_id'
      return value.join(', ') if value.is_a? Array
      return value.to_formatted_s(:datepicker) if value.is_a? Date
      return number_to_currency(value) if value.is_a? Float or value.is_a? BigDecimal or is_decimal?(value)
      return '&#10003;'.html_safe if 't' == value or true == value
      return '' if 'f' == value or false == value
      return value
    end

    def get_temp_order_direction(params)
      return 'asc' unless params[:order].present?
      current_order_column, current_order_direction = params[:order].split('-')
      {"asc" => "desc", "desc" => "asc", nil => "asc", '' => 'asc'}[current_order_direction]
    end

    def get_selected_order_direction(params, column)
      return nil unless params[:order].present?
      current_order_column, current_order_direction = params[:order].split('-')
      return nil unless column.column_name == current_order_column
      {"asc" => '&darr;'.html_safe, "desc" => '&uarr;'.html_safe}[current_order_direction]
    end

    def print_button(rows, from_modal=false)
      if rows
        onclick_str = "window.print()"
        onclick_str.prepend("$('#print_report_modal').modal('hide');") if from_modal
        link_to 'Print',
                'javascript:void(0)',
                class: 'btn',
                onclick: raw(onclick_str)
      end
    end
  end
end
