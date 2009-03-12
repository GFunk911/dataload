class FasterCSV::Row
  def method_missing(sym,*args,&b)
    if self[sym.to_s]
      self[sym.to_s].safe_to_num
    else
      super(sym,*args,&b)
    end
  end
end

class FasterCSV
  def self.each(*args,&b)
    foreach(*args,&b)
  end
end

class Object
  def safe_to_num
    if self =~ /^\d+$/
      to_i
    else
      self
    end
  end
end