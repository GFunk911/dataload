class FasterCSV::Row
  def method_missing(sym,*args,&b)
    if self[sym.to_s]
      self[sym.to_s]
    else
      super(sym,*args,&b)
    end
  end
end