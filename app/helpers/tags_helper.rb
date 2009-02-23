module TagsHelper
  # See the README for an example using tag_cloud.
  def tag_cloud(tags, classes)
    return if tags.empty?
    max_count = tags.sort_by(&:count).last.count.to_f
    tags.each do |tag|
      index = ((tag.count / max_count) * (classes.size - 1)).round
      yield tag, classes[index]
    end
  end

  def columns(size)
    4
  end

  def entries_per_column(size)
    (size/columns(size)).to_i
  end
  
  def offset i, j, size
    i*entries_per_column(size)+j
  end
end
