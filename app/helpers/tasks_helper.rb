module TasksHelper
  def category_select(form)
    categories = current_user.categories.distinct
    form.collection_select(:category_id, categories, :id, :name, { prompt: 'Selecione uma categoria' }, class: "block shadow rounded-md border border-gray-400 outline-none px-3 py-2 mt-2 w-full")
  end

  def format_changes(object_changes, event_type)
    if object_changes.present?
      changes_hash = object_changes.deep_symbolize_keys
      changes_html = ""

      translations = {
        title: "Título",
        description: "Descrição",
        category_id: "Categoria",
        commitment_id: "Compromisso",
        hours: "Horas",
        status: "Status",
        created_at: "Criado em",
        updated_at: "Atualizado em"
      }

      changes_hash.each do |attribute, values|
        translated_attribute = translations[attribute] || attribute.to_s.humanize
        before_value, after_value = values

        if attribute == :category_id
          before_value = Category.find_by(id: before_value)&.name || before_value if before_value
          after_value = Category.find_by(id: after_value)&.name || after_value if after_value
        elsif attribute == :commitment_id
          before_value = Commitment.find_by(id: before_value)&.description || before_value if before_value
          after_value = Commitment.find_by(id: after_value)&.description || after_value if after_value
        end

        before_value, after_value = [before_value, after_value].map do |value|
          if value.is_a?(String)
            if value.match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z/)
              Time.parse(value).strftime("%d/%m/%Y - %H:%M")
            elsif value.match(/\d{4}-\d{2}-\d{2}/)
              Date.parse(value).strftime("%d/%m/%Y")
            else
              value
            end
          end
        end
        
        changes_html += "<strong>#{translated_attribute}:</strong><br>"
        changes_html += "<ul class='list-none'>"
        changes_html += "<li class='flex items-center space-x-2'>"

        if event_type != "create"
          changes_html += "<span class='bg-red-500 text-white px-2 py-1 rounded'>#{before_value}</span>"
        end

        if event_type == "update"
          changes_html += "<span class='text-gray-500'>=&gt;</span>"
        end

        if event_type == "create"
          changes_html += "<span class='bg-blue-300 text-white px-2 py-1 rounded'>#{after_value}</span>"
        elsif event_type != "destroy"
          changes_html += "<span class='bg-green-500 text-white px-2 py-1 rounded'>#{after_value}</span>"
        end
        
        changes_html += "</li>"
        changes_html += "</ul>"
      end

      changes_html.html_safe

    else
      "Sem alterações registradas"
    end
  end

  def format_event_type(event_type)
    case event_type
    when "update"
      "<span class='text-green-600'>Atualização</span>".html_safe
    when "create"
      "<span class='text-blue-600'>Criação</span>".html_safe
    else
      "<span class='text-red-600'>Remoção</span>".html_safe
    end
  end
end
