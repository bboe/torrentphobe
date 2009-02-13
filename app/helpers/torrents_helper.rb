module TorrentsHelper

  def display_size size
    units = ["B","KB","MB","GB"]
    count = 0
    size = size.to_f
    while ( size / 1024 ) > 1
      size = size / 1024
      count+=1
    end

    size = (size * 10**2).round.to_f / 10**2

    return size.to_s+units[count]
  end
end
