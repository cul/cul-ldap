require 'delegate'

module Cul
  class LDAP::Entry < SimpleDelegator
    def name
      self[:cn].first
    end

    def email
      (self[:mail].empty?) ? "#{uni}@columbia.edu" : mail.first
    end

    def first_name
      self[:givenname].first
    end

    def last_name
      self[:sn].first
    end

    def organizational_unit
      self[:ou].first
    end

    def uni
      self[:uni].first
    end

    def title
      self[:title].first
    end
  end
end
