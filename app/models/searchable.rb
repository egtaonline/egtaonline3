module Searchable
  # Classes that include this modules should define general_search to
  # do the appropriate action with a general query and column_filter
  # to use the column-value pairs to filter the results. The view
  # should be set up to include the search form and the controller
  # updated to call these functions and define the default_search_column.

  def search(s)
    search = s.dup

    # parse searching language
    pattern =/[^\s="]+="[^"]*"/
    queries = search.scan(pattern)
    search.gsub!(pattern, "")
    search.upcase!
    search.strip!
    filters = {}
    for query in queries
      col, _, entry = query.partition('=')
      filters[col.downcase] = entry[1...-1].upcase # remove quotes
    end

    # call down to including class
    results = general_search(search)
    results = column_filter(results, filters)

    return results
  end

  private

  # returns all results where the name contains all of the words in search, case insensitive
  # only valid for classes with a name column
  def name_search(search)
    words = search.split(' ')
    results = where("UPPER(name) LIKE ?", "%#{words[0]}%")
    for i in 1...words.size
      results = results.where("UPPER(name) LIKE ?", "%#{words[i]}%")
    end
    return results
  end

  # as above, but filters given results
  def name_filter(results, search)
    words = search.split(' ')
    for i in 0...words.size
      results = results.where("UPPER(name) LIKE ?", "%#{words[i]}%")
    end
    return results
  end
end
