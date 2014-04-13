module AuthenticatedHelper
  def sortable(column, title = nil, secondary_column = nil)
    title ||= column.titleize
    if column == sort_column
      css_class = "current #{sort_direction.downcase}"
      direction = sort_direction == 'ASC' ? 'DESC' : 'ASC'
    end
    link_params = params.merge(sort: column, direction: direction,
                               secondary_column: secondary_column, page: nil)
    link_to title, link_params, class: css_class
  end
end
