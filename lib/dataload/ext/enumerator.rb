def enum(*args,&b)
  Enumerable::Enumerator.new(*args,&b)
end