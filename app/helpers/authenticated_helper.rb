module AuthenticatedHelper
  def sortable(column, title = nil, secondary_column = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction.downcase}" : nil
    direction = (column == sort_column && sort_direction == 'ASC') ? 'DESC' : 'ASC'
    link_to title, params.merge(sort: column, direction: direction, secondary_column: secondary_column, page: nil), { class: css_class }
  end
end
