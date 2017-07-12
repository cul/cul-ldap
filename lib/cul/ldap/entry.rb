class Cul::LDAP::Entry < SimpleDelegator
  def name
    cn.first
  end

  def email
    (mail.blank?) ? "#{uid.first}@columbia.edu" : mail.first
  end

  def first_name
    givenname.first
  end

  def last_name
    sn.first
  end

  def organizational_unit
    ou.first
  end

  # def uni
  # end

  # uni method
  # p.title = (entry[:title].kind_of?(Array) ? entry[:title].first : entry[:title]).to_s
end
