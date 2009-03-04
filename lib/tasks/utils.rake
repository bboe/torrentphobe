# 1 torrent per user
# 20 friends per user
# 10 torrents per user
# 5000 unique tags
# 3 tags per torrent

desc "Purges the old entries in the swarm table"
task( :purge_swarms => :environment) do
  Swarm.delete_all(["updated_at < ?", 1.weeks.ago])
  stale = Swarm.find(:all, :conditions => ["updated_at < ? and status != 2",
                                           5.minutes.ago])
  stale.each do | item |
    item.status = 2
    item.save()
  end
end
