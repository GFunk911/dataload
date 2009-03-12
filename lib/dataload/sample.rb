dataload do
  source "source.csv"
  database :adapter => 'sqlite3', :database => "db.sqlite3", :timeout => 5000
  table 'foobar'
  string(:cat) { bar + "_cat" }
end