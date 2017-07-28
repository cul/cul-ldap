module Cul
  class LDAP::Entry < SimpleDelegator
    def name
      cn.first
    end

    def email
      (mail.empty?) ? "#{uid.first}@columbia.edu" : mail.first
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

    def uni
      super.first
    end

    def title
      super.first
    end
  end
end
