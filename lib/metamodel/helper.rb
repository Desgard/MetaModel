class String
  def underscore
    self.scan(/[A-Z][a-z]*/).join("_").downcase
  end

  def camelize
    self.split("_").each { |s| s.capitalize! }.join("")
  end
end
